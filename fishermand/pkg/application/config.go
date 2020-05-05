package application

// Config contains necessary credentials for program
type Config struct {
	TempDirectory    string // location of temp files
	FifoPipe         string // name of fifo pipe
	UpdateFrequency  int64  // frequency to pushing to server (ms)
	MaxCmdsPerUpdate int    // max number of commands per payload sent to server
}

// ParseConfig reads in configuration values from provided flags
func ParseConfig() (*Config, error) {
	config := Config{
		TempDirectory:    "/tmp/fisherman/",
		FifoPipe:         "/tmp/fisherman/cmdpipe",
		UpdateFrequency:  int64(0),
		MaxCmdsPerUpdate: 1,
	}
	return &config, nil
}
