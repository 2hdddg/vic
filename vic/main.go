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
	"github.com/docker/docker/api/types/mount"
	"github.com/docker/docker/api/types/strslice"
	"github.com/docker/docker/client"
	"golang.org/x/term"
	"gopkg.in/yaml.v2"
)

/*
images:
  - java-openjdk-11:
      tag: stable
  - java-openjdk-17:
      tag: stable
  - go-1.17:
      tag: stable
  - nvim
      tag: stable
roots:
  - /home/peter/code/neo-technology/neo4j-dev:
     image: java-openjdk-17
  - /home/peter/code/neo-technology/neo4j-4.x:
     image: java-openjdk-11
default:
  image: nvim
filters:
  - *.java:
    image: java-openjdk-11
  - pom.xml:
    image: java-openjdk-11
  - *.go:
    image: go-1.17
verbose: true|false
*/
type Config struct {
	Images  map[string]ImageConfig
	Roots   map[string]RootConfig
	Default RootConfig
	Filters map[string]RootConfig
	Verbose bool
}

func (c Config) configure(containerConfig *container.Config, hostConfig *container.HostConfig, rootPath string, rootConfig RootConfig) error {
	imageConfig, found := c.Images[rootConfig.Image]
	if !found {
		return fmt.Errorf("No configuration for image: %s", rootConfig.Image)
	}
	workspacePath, err := c.workspace(rootConfig, rootPath)
	if err != nil {
		return err
	}
	containerConfig.Image = fmt.Sprintf("vic-%s:%s", rootConfig.Image, imageConfig.Tag)
	containerConfig.WorkingDir = "/host/code"
	containerConfig.Cmd = strslice.StrSlice([]string{"nvim", "."})
	hostConfig.Mounts = []mount.Mount{
		{Type: "bind", Target: "/host/code", Source: rootPath},
		{Type: "bind", Target: "/host/workspace", Source: workspacePath},
	}
	dataPath, err := c.data(rootConfig, rootPath)
	if err != nil {
		return err
	}
	if dataPath != "" {
		dataMount := mount.Mount{Type: "bind", Target: "/host/data", Source: dataPath}
		hostConfig.Mounts = append(hostConfig.Mounts, dataMount)
	}
	return nil
}

func (c Config) workspace(rootConfig RootConfig, rootPath string) (path string, err error) {
	if rootConfig.Workspace != "" {
		path = rootConfig.Workspace
	} else {
		path = c.Default.Workspace
	}
	if path == "" {
		err = fmt.Errorf("No workspace configured for: %s", rootPath)
		return
	}
	path = pathRelativeToRoot(path, rootPath)
	// Ensure that workspace directory exists
	err = os.MkdirAll(path, os.ModePerm)
	return
}

func (c Config) data(rootConfig RootConfig, rootPath string) (path string, err error) {
	if rootConfig.Data != "" {
		path = rootConfig.Data
	} else {
		path = c.Default.Data
	}
	// A missing data path is not an error
	if path == "" {
		return
	}
	path = pathRelativeToRoot(path, rootPath)
	return
}

func pathRelativeToRoot(apath, root string) string {
	if path.IsAbs(apath) {
		return apath
	}
	return path.Join(root, apath)
}

func (c Config) byPath(path string) (containerConfig container.Config, hostConfig container.HostConfig, err error) {
	// Try to find a matching root
	for name, rootConfig := range c.Roots {
		if strings.HasPrefix(path, name) {
			err = c.configure(&containerConfig, &hostConfig, name, rootConfig)
			return
		}
	}
	err = fmt.Errorf("No suitable image found for %s", path)
	return
}

type ImageConfig struct {
	Tag string
}

type RootConfig struct {
	Image     string // Name of image
	Workspace string // Path to workspace, if path is relative it is relative to the root
	Data      string // Path to data
}

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
	containerName := buildContainerId(wd)
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

	cli, err := client.NewClientWithOpts()
	if err != nil {
		panic(err)
	}

	createResponse, err := cli.ContainerCreate(context.Background(), &containerConfig, &hostConfig, nil, nil, containerName)
	if err != nil {
		panic(err)
	}
	containerId := createResponse.ID

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

	attachOptions := types.ContainerAttachOptions{
		Stdin:  true,
		Stderr: true,
		Stdout: true,
		Stream: true,
	}
	attachResponse, err := cli.ContainerAttach(context.Background(), containerId, attachOptions)
	if err != nil {
		panic(err)
	}
	go io.Copy(os.Stdout, attachResponse.Reader)
	go io.Copy(attachResponse.Conn, os.Stdin)

	err = cli.ContainerStart(context.Background(), containerId, types.ContainerStartOptions{})
	if err != nil {
		panic(err)
	}

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
			return
		}
	}
}

func buildContainerId(workingDirectory string) string {
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
