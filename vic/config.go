package main

import (
	"fmt"
	"os"
	"os/user"
	"path"
	"strings"

	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/api/types/mount"
	"github.com/docker/docker/api/types/strslice"
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
