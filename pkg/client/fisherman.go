package client

import (
	"github.com/pkg/errors"
)

// FishermanAPI for interacting with Fisherman. This is the top level API for the client.
type FishermanAPI interface {
	Start() error
}

// Fisherman contains necessary data for top level API methods
type Fisherman struct {
	Config     *Config
	Consumer   *Consumer
	Dispatcher *Dispatcher
}

// NewFisherman returns a new instance of Fisherman
func NewFisherman(cfg *Config) *Fisherman {
	buffer := NewBuffer()
	dispatcher := NewDispatcher()
	consumer := NewConsumer(
		cfg.FifoPipe,
		buffer,
		dispatcher,
		cfg.UpdateFrequency,
		cfg.MaxCmdsPerUpdate,
	)
	return &Fisherman{
		Config:     cfg,
		Consumer:   consumer,
		Dispatcher: dispatcher,
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
