package fisherman

import (
	"github.com/pkg/errors"

	"github.com/henrysdev/fisherman/pkg/client"
	"github.com/henrysdev/fisherman/pkg/cmdpipeline"
	"github.com/henrysdev/fisherman/pkg/config"
)

// API for interacting with Fisherman
type API interface {
	Start() error
	/*:
	ViewHistory() (History, error)
	ViewTimeline() (Timeline, error)
	*/
}

// Fisherman contains necessary data for top level API methods
type Fisherman struct {
	Config   *config.Config
	Consumer *cmdpipeline.Consumer
	Client   *client.Dispatcher
}

// NewFisherman returns a new instance of Fisherman
func NewFisherman(cfg *config.Config) *Fisherman {
	buffer := cmdpipeline.NewBuffer()
	client := client.NewDispatcher()
	consumer := cmdpipeline.NewConsumer(
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
