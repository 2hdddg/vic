package main

import (
	"context"
	"fmt"
	"io"
	"os"
	"os/signal"
	"path"
	"strings"
	"syscall"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/api/types/filters"
	"github.com/docker/docker/client"
	"golang.org/x/term"
	"gopkg.in/yaml.v2"
)

func main() {
	configuration, err := getOrCreateConfiguration()
	if err != nil {
		panic(err)
	}
	wd, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	// Builds basic container configuration
	containerName := buildContainerName(wd)
	containerConfig, hostConfig, err := configuration.byPath(wd)
	if err != nil {
		panic(err)
	}
	if configuration.Verbose {
		fmt.Printf("Starting container based on image %s with name %s:\n", containerConfig.Image, containerName)
		for _, mount := range hostConfig.Mounts {
			fmt.Printf("   %s -> %s\n", mount.Target, mount.Source)
		}
	}
	// Add more specifics to the configuration
	containerConfig.Tty = true
	containerConfig.AttachStderr = true
	containerConfig.AttachStdin = true
	containerConfig.AttachStdout = true
	containerConfig.OpenStdin = true
	containerConfig.StdinOnce = true
	hostConfig.AutoRemove = true

	fd := int(os.Stdin.Fd())
	if term.IsTerminal(fd) {
		oldState, err := term.MakeRaw(fd)
		if err != nil {
			panic(err)
		}
		defer term.Restore(fd, oldState)
	} else {
		panic("Should be terminal")
	}

	cli, err := client.NewClientWithOpts()
	if err != nil {
		panic(err)
	}

	err = runInNewContainer(fd, cli, containerName, containerConfig, hostConfig)
	if err != nil {
		err = tryExecInExistingContainer(fd, cli, containerName, containerConfig, hostConfig)
		if err != nil {
			panic(err)
		}
	}
}

func runInNewContainer(fd int, cli *client.Client, containerName string, containerConfig container.Config, hostConfig container.HostConfig) error {
	createResponse, err := cli.ContainerCreate(context.Background(), &containerConfig, &hostConfig, nil, nil, containerName)
	if err != nil {
		return err
	}
	containerId := createResponse.ID

	attachOptions := types.ContainerAttachOptions{
		Stdin:  true,
		Stderr: true,
		Stdout: true,
		Stream: true,
	}
	hijackedResponse, err := cli.ContainerAttach(context.Background(), containerId, attachOptions)
	if err != nil {
		return err
	}
	err = cli.ContainerStart(context.Background(), containerId, types.ContainerStartOptions{})
	if err != nil {
		return err
	}
	go io.Copy(os.Stdout, hijackedResponse.Reader)
	go io.Copy(hijackedResponse.Conn, os.Stdin)

	winchSignalCh := make(chan os.Signal, 1)
	signal.Notify(winchSignalCh, syscall.SIGWINCH)
	resize := func() {
		width, height, _ := term.GetSize(fd)
		cli.ContainerResize(context.Background(), containerId, types.ResizeOptions{Width: uint(width), Height: uint(height)})
	}

	statusCh, errCh := cli.ContainerWait(context.Background(), containerId, container.WaitConditionNotRunning)
	resize()
	for {
		select {
		case <-winchSignalCh:
			resize()
		case err := <-errCh:
			if err != nil {
				panic(err)
			}
		case _ = <-statusCh:
			return nil
		}
	}
}

func tryExecInExistingContainer(fd int, cli *client.Client, containerName string, containerConfig container.Config, hostConfig container.HostConfig) error {
	execConfig := types.ExecConfig{
		Tty:          containerConfig.Tty,
		AttachStderr: containerConfig.AttachStderr,
		AttachStdin:  containerConfig.AttachStdin,
		AttachStdout: containerConfig.AttachStdout,
		Env:          containerConfig.Env,
		WorkingDir:   containerConfig.WorkingDir,
		Cmd:          []string{"/bin/bash"},
	}
	//var x types.ContainerExecInspect
	idResponse, err := cli.ContainerExecCreate(context.Background(), containerName, execConfig)
	containerId := idResponse.ID
	if err != nil {
		return err
	}
	execCheck := types.ExecStartCheck{Tty: true}
	hijackedResponse, err := cli.ContainerExecAttach(context.Background(), idResponse.ID, execCheck)
	if err != nil {
		return err
	}
	err = cli.ContainerExecStart(context.Background(), idResponse.ID, execCheck)
	if err != nil {
		return err
	}
	go io.Copy(os.Stdout, hijackedResponse.Reader)
	go io.Copy(hijackedResponse.Conn, os.Stdin)

	winchSignalCh := make(chan os.Signal, 1)
	signal.Notify(winchSignalCh, syscall.SIGWINCH)
	resize := func() {
		width, height, _ := term.GetSize(fd)
		cli.ContainerExecResize(context.Background(), containerId, types.ResizeOptions{Width: uint(width), Height: uint(height)})
	}
	eventCh, errCh := cli.Events(context.Background(), types.EventsOptions{Filters: filters.NewArgs()})
	resize()
	for {
		select {
		case <-winchSignalCh:
			resize()
		case err := <-errCh:
			if err != nil {
				panic(err)
			}
		case msg := <-eventCh:
			if msg.Action == "exec_die" || msg.Action == "die" {
				return nil
			}
		}
	}

	return nil
}

func buildContainerName(workingDirectory string) string {
	return "vic_" + strings.ReplaceAll(workingDirectory, "/", "_")
}

func getOrCreateConfiguration() (config Config, err error) {
	var (
		dirPath  string
		filePath string
		file     *os.File
	)
	dirPath, err = os.UserConfigDir()
	if err != nil {
		return
	}
	dirPath = path.Join(dirPath, "vic")
	filePath = path.Join(dirPath, "config.yaml")
	file, err = os.Open(filePath)
	if err != nil {
		if !os.IsNotExist(err) {
			return
		}
		err = os.MkdirAll(dirPath, 0700)
		if err != nil {
			return
		}
		file, err = os.Create(filePath)
		if err != nil {
			return
		}
		defer file.Close()
		encoder := yaml.NewEncoder(file)
		config = defaultConfiguration()
		encoder.Encode(config)
		return
	}

	decoder := yaml.NewDecoder(file)
	err = decoder.Decode(&config)
	return
}

func defaultConfiguration() Config {
	return Config{
		Images: map[string]ImageConfig{
			"java-openjdk-11": {Tag: "stable"},
			"java-openjdk-17": {Tag: "stable"},
			"nvim":            {Tag: "stable"},
		},
		Default: RootConfig{Image: "nvim"},
		Filters: map[string]RootConfig{
			"pom.xml": {Image: "java-openjdk-11"},
			"*.java":  {Image: "java-openjdk-11"},
		},
		Roots: map[string]RootConfig{},
	}
}
