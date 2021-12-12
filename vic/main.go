package main

import (
	"context"
	"fmt"
	"io"
	"os"
	"os/signal"
	"os/user"
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
  verbose: true
  gitconfig: /home/peter/.gitconfig
  configs:
    - git: /home/peter/.config/git

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
	containerConfig.Image = fmt.Sprintf("vic-%s:%s", rootConfig.Image, imageConfig.Tag)
	containerConfig.WorkingDir = "/host/code"
	containerConfig.Cmd = strslice.StrSlice([]string{"nvim", "."})
	rootConfig = rootConfig.inherit(c.Default)
	mounts, err := rootConfig.build(rootPath)
	if err != nil {
		return err
	}
	hostConfig.Mounts = mounts
	return nil
}

func pathRelativeToRoot(apath, root string) string {
	if apath == "" {
		return apath
	}
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
	Image     string            // Name of image
	Workspace string            // Path to workspace, if path is relative it is relative to the root
	Data      string            // Path to data
	Gitconfig string            // Path to git configuration, typically ~/.gitconfig (single file)
	Gpg       string            // Path to GPG secret keys, typically ~/.gnupg or local for root
	Ssh       string            // Path to ssh keys, typically ~/.ssh or local for root
	Configs   map[string]string // Application configurations, mounted to ~/.config/xx or local for root
}

func (this RootConfig) inherit(parent RootConfig) RootConfig {
	if this.Image == "" {
		this.Image = parent.Image
	}
	if this.Workspace == "" {
		this.Workspace = parent.Workspace
	}
	if this.Data == "" {
		this.Data = parent.Data
	}
	if this.Gitconfig == "" {
		this.Gitconfig = parent.Gitconfig
	}
	if this.Gpg == "" {
		this.Gpg = parent.Gpg
	}
	if this.Ssh == "" {
		this.Ssh = parent.Ssh
	}
	if this.Configs == nil {
		this.Configs = parent.Configs
	}
	return this
}

func (this RootConfig) build(rootPath string) (mounts []mount.Mount, err error) {
	if this.Workspace == "" {
		err = fmt.Errorf("No workspace configured for: %s", rootPath)
		return
	}
	this.Workspace = pathRelativeToRoot(this.Workspace, rootPath)
	// Ensure that workspace directory exists
	err = os.MkdirAll(this.Workspace, os.ModePerm)
	if err != nil {
		return
	}
	this.Gitconfig = pathRelativeToRoot(this.Gitconfig, rootPath)
	this.Gpg = pathRelativeToRoot(this.Gpg, rootPath)
	this.Ssh = pathRelativeToRoot(this.Ssh, rootPath)
	if this.Configs != nil {
		for k, v := range this.Configs {
			this.Configs[k] = pathRelativeToRoot(v, rootPath)
		}
	}

	// Stuff to mount into user home directory on container
	homeDirectory := ""
	getHomeDirectory := func() string {
		if homeDirectory != "" {
			return homeDirectory
		}
		var hostUser *user.User
		hostUser, err = user.Current()
		if err != nil {
			return ""
		}
		homeDirectory = fmt.Sprintf("/home/%s/", hostUser.Username)
		return homeDirectory
	}

	// Build mounts
	mounts = append(mounts, mount.Mount{Type: "bind", Target: "/host/code", Source: rootPath})
	mounts = append(mounts, mount.Mount{Type: "bind", Target: "/host/workspace", Source: this.Workspace})
	if this.Gitconfig != "" {
		mounts = append(mounts, mount.Mount{Type: "bind", Target: path.Join(getHomeDirectory(), ".gitconfig"), Source: this.Gitconfig})
	}
	if this.Gpg != "" {
		mounts = append(mounts, mount.Mount{Type: "bind", Target: path.Join(getHomeDirectory(), ".gnupg"), Source: this.Gpg})
	}
	if this.Ssh != "" {
		mounts = append(mounts, mount.Mount{Type: "bind", Target: path.Join(getHomeDirectory(), ".ssh"), Source: this.Ssh})
	}
	if this.Configs != nil {
		for k, v := range this.Configs {
			mounts = append(mounts, mount.Mount{Type: "bind", Target: path.Join(getHomeDirectory(), ".config", k), Source: v})
		}
	}

	return
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
