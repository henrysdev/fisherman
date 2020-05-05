package application

import (
	"io/ioutil"
	"testing"

	"gopkg.in/yaml.v2"

	"github.com/henrysdev/fisherman/fishermand/pkg/utils"
)

var (
	dummycfg = "dummycfg.yml"
)

func genDummyYamlFile(config *Config) {
	bytes, _ := yaml.Marshal(config)
	ioutil.WriteFile(dummycfg, bytes, 0644)
}

func cleanupDummyYamlFile() {
	utils.RemoveFile(dummycfg)
}

func TestParseConfig(t *testing.T) {
	// Arrange
	expectedCfg := &Config{
		TempDirectory:    ".",
		FifoPipe:         ".",
		UpdateFrequency:  int64(0),
		MaxCmdsPerUpdate: 1,
	}
	genDummyYamlFile(expectedCfg)
	defer cleanupDummyYamlFile()

	// Act
	cfg, err := ParseConfig(dummycfg)

	// Assert
	if err != nil {
		t.Errorf("Err should be nil, was %v", err)
	}
	if expectedCfg.TempDirectory != cfg.TempDirectory {
		t.Errorf("TempDirectory not the same")
	}
	if expectedCfg.FifoPipe != cfg.FifoPipe {
		t.Errorf("FifoPipe not the same")
	}
	if expectedCfg.UpdateFrequency != cfg.UpdateFrequency {
		t.Errorf("UpdateFrequency not the same")
	}
	if expectedCfg.MaxCmdsPerUpdate != cfg.MaxCmdsPerUpdate {
		t.Errorf("MaxCmdsPerUpdate not the same")
	}
}
