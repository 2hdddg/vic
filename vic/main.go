package main

import (
	"context"
	"fmt"
	"io"
	"os"
	"path"
	"strings"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
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
*/
type Config struct {
	Images  map[string]ImageConfig
	Roots   map[string]RootConfig
	Default RootConfig
	Filters map[string]RootConfig
}

func (c Config) getTag(image string) (string, error) {
	for configuredImage, imageConfig := range c.Images {
		if configuredImage == image {
			return imageConfig.Tag, nil
		}
	}
	return "", fmt.Errorf("No configuration for image: %s", image)
}

func (c Config) getContainerConfig(root string) (cc container.Config, err error) {
	// Try to find a matching root
	for configuredRoot, imageConfig := range c.Roots {
		if strings.HasPrefix(root, configuredRoot) {
			var tag string
			tag, err = c.getTag(imageConfig.Image)
			cc.Image = fmt.Sprintf("vic-%s:%s", imageConfig.Image, tag)
			return
		}
	}
	return cc, fmt.Errorf("No suitable image found for %s", root)
}

type ImageConfig struct {
	Tag string
}

type RootConfig struct {
	Image string
}

func main() {
	config, err := getConfig()
	if err != nil {
		panic(err)
	}
	wd, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	// Builds basic container configuration
	containerConfig, err := config.getContainerConfig(wd)
	if err != nil {
		panic(err)
	}
	// Add more specifics to the configuration
	containerConfig.Tty = true
	containerConfig.AttachStderr = true
	containerConfig.AttachStdin = true
	containerConfig.AttachStdout = true
	containerConfig.OpenStdin = true
	containerConfig.StdinOnce = true
	containerConfig.WorkingDir = "/host/code"

	containerName := buildContainerId(wd)
	fmt.Printf("Will run or exec container '%s' configures as %+v\n", containerName, containerConfig)
	cli, err := client.NewClientWithOpts()
	if err != nil {
		panic(err)
	}

	hostConfig := container.HostConfig{}
	hostConfig.AutoRemove = true
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
	//go io.Copy(os.Stderr, attachResponse.Reader)
	go io.Copy(attachResponse.Conn, os.Stdin)

	err = cli.ContainerStart(context.Background(), containerId, types.ContainerStartOptions{})
	if err != nil {
		panic(err)
	}

	statusCh, errCh := cli.ContainerWait(context.Background(), containerId, container.WaitConditionNotRunning)
	select {
	case err := <-errCh:
		if err != nil {
			panic(err)
		}
	case status := <-statusCh:
		fmt.Println(status)
	}
	/*

		containers, err := cli.ContainerList(context.Background(), types.ContainerListOptions{})
		if err != nil {
			panic(err)
		}
		fmt.Println(containers)
	*/
}

func buildContainerId(workingDirectory string) string {
	return "vic_" + strings.ReplaceAll(workingDirectory, "/", "_")
}

func getConfig() (config Config, err error) {
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
		config = getDefaultConfig()
		encoder.Encode(config)
		return
	}

	decoder := yaml.NewDecoder(file)
	err = decoder.Decode(&config)
	return
}

func getDefaultConfig() Config {
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
