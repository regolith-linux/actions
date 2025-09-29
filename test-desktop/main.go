package main

import (
	"bytes"
	_ "embed" //nolint
	"fmt"
	"html/template"
	"os"
	"path/filepath"
)

type distribution string

const (
	Debian distribution = "debian"
	Ubuntu distribution = "ubuntu"
)

var supportedDistros = []distribution{Debian, Ubuntu}

//go:embed _templates/test-docker.tmpl
var tplDockerTest []byte

//go:embed _templates/test-repo.tmpl
var tplRepoTest []byte

func main() {
	distros, err := getDistros()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %s\n", err.Error())
		os.Exit(1)
	}

	if err := renderFiles(tplDockerTest, "test-docker", distros); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %s\n", err.Error())
		os.Exit(1)
	}

	if err = renderFiles(tplRepoTest, "test-repo", distros); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %s\n", err.Error())
		os.Exit(1)
	}
}

type Distro struct {
	Name  string
	Codes []string
}

func getDistros() ([]Distro, error) {
	file, err := os.Open("test-desktop")
	if err != nil {
		return nil, err
	}
	defer file.Close()

	dirs, err := os.ReadDir(file.Name())
	if err != nil {
		return nil, err
	}

	distros := []Distro{}

	for _, d := range dirs {
		if !d.IsDir() {
			continue
		}
		if !isDistroSupported(d.Name()) {
			continue
		}

		dist := Distro{
			Name: d.Name(),
		}

		subdirs, err := os.ReadDir(filepath.Join("test-desktop", d.Name()))
		if err != nil {
			return nil, err
		}

		for _, s := range subdirs {
			if !s.IsDir() {
				continue
			}
			dist.Codes = append(dist.Codes, s.Name())
		}

		distros = append(distros, dist)
	}

	return distros, nil
}

func isDistroSupported(name string) bool {
	for _, d := range supportedDistros {
		if string(d) == name {
			return true
		}
	}
	return false
}

func renderFiles(tpl []byte, name string, distros []Distro) error {
	tmpl, err := template.New(name).Parse(string(tpl))
	if err != nil {
		return err
	}

	var buffer bytes.Buffer
	if err := tmpl.ExecuteTemplate(&buffer, name, distros); err != nil {
		return err
	}

	newpath := filepath.Join(".github", "workflows")
	if err := os.MkdirAll(newpath, os.ModePerm); err != nil {
		return err
	}

	return os.WriteFile(fmt.Sprintf(".github/workflows/%s.yml", name), buffer.Bytes(), 0644)
}
