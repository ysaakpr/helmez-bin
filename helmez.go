package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"

	"github.com/icza/dyno"
	"github.com/imdario/mergo"
	"github.com/urfave/cli"
	"gopkg.in/yaml.v2"
)

//DefaultPath is the default path in case no paths are provided
var DefaultPath = "./"

//ConfigFile the config file name to configure the helmez
var ConfigFile = "helmez.yaml"

var defaultHelmezConfig HelmezConfig

func main() {
	app := cli.NewApp()

	defaultHelmezConfig = HelmezConfig{
		ValuesFileName: "values.yaml",
		IgnoreDotFile:  true,
		ExtraFilesToKV: true,
		ExtraFileRoot:  []string{"config", "files"},
		IgnoredFiles:   []string{},
	}

	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:  "base, b",
			Usage: "Execute in base directory `BASE`",
			Value: "./",
		},

		cli.StringFlag{
			Name:  "dir, d",
			Usage: "default folder name `DIR`, default `values`",
			Value: "values",
		},

		cli.StringFlag{
			Name:  "out, o",
			Usage: "write the generate yaml to file `values.yaml`",
			Value: "values.yaml",
		},

		cli.StringFlag{
			Name:  "helmez",
			Usage: "default helmez config file `HELMEZ`",
			Value: "helmez.yaml",
		},
	}

	app.Action = Run

	err := app.Run(os.Args)
	if err != nil {
		log.Fatal(err)
	}
}

// Run runs the application
func Run(c *cli.Context) error {
	base := c.String("base")
	dir := c.String("dir")
	out := c.String("out")
	v := prepareValuesFile(base, dir, defaultHelmezConfig)
	d, err := yaml.Marshal(&v)
	if err != nil {
		return err
	}
	err = ioutil.WriteFile(out, d, 0644)
	return err
}

// HelmezConfig config for helmez
type HelmezConfig struct {
	ValuesFileName string   `yaml:"values_file_name"`
	IgnoreDotFile  bool     `yaml:"ignore_dot_file"`
	ExtraFilesToKV bool     `yaml:"extra_files_to_kv"`
	ExtraFileRoot  []string `yaml:"extra_files_root"`
	IgnoredFiles   []string `yaml:"ignored_files"`
}

func isValidFile(config HelmezConfig, fi os.FileInfo) bool {
	if fi.Name() != config.ValuesFileName && fi.Name() != ConfigFile {
		if config.IgnoreDotFile && strings.HasPrefix(fi.Name(), ".") {
			return false
		}

		for _, val := range config.IgnoredFiles {
			if fi.Name() == val {
				return false
			}
		}
		return true
	}
	return false

}

func prepareValuesFile(base string, dir string, parent HelmezConfig) interface{} {
	folder := base + dir + "/"

	hConfig := new(HelmezConfig)
	if err := mergo.Merge(hConfig, parent); err != nil {
		log.Fatal(err)
	}

	helmezOvr := new(HelmezConfig)
	helmez, err := ioutil.ReadFile(folder + ConfigFile)
	if err == nil {
		yaml.Unmarshal(helmez, helmezOvr)
		if err := mergo.Merge(hConfig, helmezOvr, mergo.WithOverride); err != nil {
			log.Fatal(err)
		}
	}

	valuesFile := hConfig.ValuesFileName
	data, err := ioutil.ReadFile(folder + valuesFile)
	if err != nil {
		log.Fatal(err)
	}

	subs, er := ioutil.ReadDir(folder)
	if er != nil {
		log.Fatal(er)
	}

	files := make(map[string]string)
	deps := make(map[string]interface{})
	for _, fi := range subs {
		if isValidFile(*hConfig, fi) {
			if fi.IsDir() {
				deps[fi.Name()] = prepareValuesFile(folder, fi.Name(), *hConfig)
			} else if hConfig.ExtraFilesToKV {
				data, err := ioutil.ReadFile(folder + fi.Name())
				if err != nil {
					log.Fatal(err)
				}

				files[fi.Name()] = string(data[:])
			}
		}
	}

	var v interface{}
	if err := yaml.Unmarshal([]byte(data), &v); err != nil {
		panic(err)
	}

	if len(files) > 0 {
		if err = dyno.Set(v, files, "config", "files"); err != nil {
			fmt.Printf("unable : %v\n", err)
		}
	}

	if len(deps) > 0 {
		for key, val := range deps {
			if err = dyno.Set(v, val, key); err != nil {
				fmt.Printf("unable : %v\n", err)
			}
		}
	}

	return v
}
