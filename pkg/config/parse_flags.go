package config

import (
	"errors"
	"flag"
)

// Config contains necessary credentials for program
type Config struct {
	APIKey      string
	HostURL     string
	PollRate    int64 // ms between each polling
	HistoryFile string
}

// ParseFlags reads in configuration values from provided flags
func ParseFlags() (*Config, error) {
	config := Config{}
	flag.StringVar(&config.APIKey, "api_key", "", "client api key to establish server")
	flag.StringVar(&config.HostURL, "host_url", "", "server host to point to")
	flag.Int64Var(&config.PollRate, "poll_rate", 1000, "rate of polling bash history (ms between polls)")
	flag.StringVar(&config.HistoryFile, "history_file", ".local/share/fish/fish_history", "fish history file location")
	if config.APIKey == "" {
		return nil, errors.New("Missing required api_key command line flag")
	}
	if config.HostURL == "" {
		return nil, errors.New("Missing required host_url command line flag")
	}
	return &config, nil
}
