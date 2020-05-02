package client

import (
	"flag"
)

// Config contains necessary credentials for program
type Config struct {
	HistoryFile      string
	UpdateFrequency  int64
	MaxCmdsPerUpdate int
}

// ParseFlags reads in configuration values from provided flags
func ParseFlags() (*Config, error) {
	config := Config{}
	flag.StringVar(&config.HistoryFile, "history_file", "/tmp/fisherman_fifo", "fish history file location")
	flag.Int64Var(&config.UpdateFrequency, "update_frequency", int64(0), "frequency to push new history to server (ms)")
	flag.IntVar(&config.MaxCmdsPerUpdate, "max_cmds_per_update", 1, "max number of commands per payload sent to server")
	return &config, nil
}
