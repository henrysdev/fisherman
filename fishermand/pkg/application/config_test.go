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

func genBadDummyYamlFile(config *Config) {
	bytes, _ := yaml.Marshal(config)
	bytes = append(bytes, []byte("io3pjkals;d")...)
	ioutil.WriteFile(dummycfg, bytes, 0644)
}

func cleanupDummyYamlFile() {
	utils.RemoveFile(dummycfg)
}

func TestParseConfig(t *testing.T) {
	// Arrange
	expectedCfg := &Config{
		TempDirectory:    ".",
		ShellPipe:        ".",
		UpdateFrequency:  int64(0),
		MaxCmdsPerUpdate: 1,
		UserID:           "abc-123-def-456",
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
	if expectedCfg.ShellPipe != cfg.ShellPipe {
		t.Errorf("ShellPipe not the same")
	}
	if expectedCfg.UpdateFrequency != cfg.UpdateFrequency {
		t.Errorf("UpdateFrequency not the same")
	}
	if expectedCfg.MaxCmdsPerUpdate != cfg.MaxCmdsPerUpdate {
		t.Errorf("MaxCmdsPerUpdate not the same")
	}
	if expectedCfg.UserID != cfg.UserID {
		t.Errorf("UserID not the same")
	}
}

func TestParseConfig_WhenNoFile_Error(t *testing.T) {
	// Act
	cfg, err := ParseConfig(dummycfg)

	// Assert
	if err == nil {
		t.Error("Err should not be nil")
	}
	if cfg != nil {
		t.Errorf("Config should be nil, got %v", cfg)
	}
}

func TestParseConfig_Malformatted_Error(t *testing.T) {
	// Arrange
	expectedCfg := &Config{
		TempDirectory:    ".",
		ShellPipe:        ".",
		UpdateFrequency:  int64(0),
		MaxCmdsPerUpdate: 1,
		UserID:           "abc-123-def-456",
	}
	genBadDummyYamlFile(expectedCfg)
	defer cleanupDummyYamlFile()

	// Act
	cfg, err := ParseConfig(dummycfg)

	// Assert
	if err == nil {
		t.Error("Err should not be nil")
	}
	if cfg != nil {
		t.Errorf("Config should be nil, got %v", cfg)
	}
}
