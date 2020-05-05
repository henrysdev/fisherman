package application

import (
	"io/ioutil"
	"log"

	"gopkg.in/yaml.v2"
)

// Config contains necessary credentials for program
type Config struct {
	TempDirectory    string `yaml:"temp_dir"`            // location of temp files
	FifoPipe         string `yaml:"fifo_pipe"`           // name of fifo pipe
	UpdateFrequency  int64  `yaml:"update_frequency"`    // frequency to pushing to server (ms)
	MaxCmdsPerUpdate int    `yaml:"max_cmds_per_update"` // max number of commands per payload sent to server
}

// ParseConfig reads in configuration values from provided flags
func ParseConfig(cfgFilepath string) (*Config, error) {

	var config Config
	yamlFile, err := ioutil.ReadFile(cfgFilepath)
	if err != nil {
		log.Printf("yamlFile.Get err   #%v ", err)
	}
	err = yaml.Unmarshal(yamlFile, &config)
	if err != nil {
		log.Fatalf("Unmarshal: %v", err)
	}

	return &config, nil
}
