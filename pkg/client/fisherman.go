package client

import (
	"github.com/pkg/errors"
)

// FishermanAPI for interacting with Fisherman
type FishermanAPI interface {
	Start() error
	/*:
	ViewHistory() (History, error)
	ViewTimeline() (Timeline, error)
	*/
}

// Fisherman contains necessary data for top level API methods
type Fisherman struct {
	Config   *Config
	Consumer *Consumer
	Client   *Dispatcher
}

// NewFisherman returns a new instance of Fisherman
func NewFisherman(cfg *Config) *Fisherman {
	buffer := NewBuffer()
	client := NewDispatcher()
	consumer := NewConsumer(
		cfg.HistoryFile,
		buffer,
		client,
		cfg.UpdateFrequency,
		cfg.MaxCmdsPerUpdate,
	)
	return &Fisherman{
		Config:   cfg,
		Consumer: consumer,
		Client:   client,
	}
}

// Start should be called immediately after instantiation
func (f *Fisherman) Start() error {

	// Setup command consumer
	if err := f.Consumer.Setup(); err != nil {
		return errors.Wrap(err, "Fisherman failed to setup Consumer")
	}

	// Spawn off async processes
	errorChan := make(chan error)
	defer close(errorChan)

	// Start listening for commands
	go f.Consumer.Listen(errorChan)

	return <-errorChan
}
