package application

import (
	"fmt"
	"io/ioutil"

	"github.com/pkg/errors"
	"gopkg.in/yaml.v2"

	"github.com/henrysdev/fisherman/fishermand/pkg/common"
	"github.com/henrysdev/fisherman/fishermand/pkg/utils"
)

// Config contains necessary credentials for program
type Config struct {
	TempDirectory    string       `yaml:"temp_dir"`            // location of temp files
	ShellPipe        string       `yaml:"shell_pipe"`          // name of shell fifo pipe
	UpdateFrequency  int64        `yaml:"update_frequency"`    // frequency to pushing to server (ms)
	MaxCmdsPerUpdate int          `yaml:"max_cmds_per_update"` // max number of commands per payload sent to server
	HostURL          string       `yaml:"host_url"`            // server host url
	User             *common.User `yaml:"user"`                // user object
}

// ParseConfig reads in configuration values from provided flags
func ParseConfig(cfgFilepath string) (*Config, error) {
	if !utils.FileExists(cfgFilepath) {
		return nil, fmt.Errorf("config file does not exist at path %s", cfgFilepath)
	}
	var config Config
	yamlFile, err := ioutil.ReadFile(cfgFilepath)
	if err != nil {
		return nil, errors.Wrap(err, "unable to read config file")
	}
	err = yaml.Unmarshal(yamlFile, &config)
	if err != nil {
		return nil, errors.Wrap(err, "unable to unmarshal config file")
	}

	return &config, nil
}
