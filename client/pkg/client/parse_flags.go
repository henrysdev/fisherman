package client

import (
	"flag"
)

// Config contains necessary credentials for program
type Config struct {
	FifoPipe         string
	UpdateFrequency  int64
	MaxCmdsPerUpdate int
}

// ParseFlags reads in configuration values from provided flags
func ParseFlags() (*Config, error) {
	config := Config{}
	flag.StringVar(&config.FifoPipe, "fifo_pipe", "/tmp/fisherman_fifo", "location of fifo pipe")
	flag.Int64Var(&config.UpdateFrequency, "update_frequency", int64(0), "frequency to pushing to server (ms)")
	flag.IntVar(&config.MaxCmdsPerUpdate, "max_cmds_per_update", 1, "max number of commands per payload sent to server")
	return &config, nil
}
