package main

import (
	"fmt"
	"os"
	"path"

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

type ImageConfig struct {
	Tag string
}

type RootConfig struct {
	Image string
}

func main() {
	//fmt.Println(os.Args)
	_, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	//fmt.Println(wd)
	config, err := openConfig()
	if err != nil {
		panic(err)
	}
	fmt.Println(config)
}

func openConfig() (config Config, err error) {
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
