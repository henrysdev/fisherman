package application

import (
	"github.com/pkg/errors"

	"github.com/henrysdev/fisherman/client/pkg/http_client"
	"github.com/henrysdev/fisherman/client/pkg/message_apid"
)

// FishermanAPI for interacting with Fisherman. This is the top level API for the client.
type FishermanAPI interface {
	Start() error
}

// Fisherman contains necessary data for top level API methods
type Fisherman struct {
	Config     *Config
	Consumer   *message_apid.Consumer
	Dispatcher *http_client.Dispatcher
}

// NewFisherman returns a new instance of Fisherman
func NewFisherman(cfg *Config) *Fisherman {
	buffer := message_apid.NewBuffer()
	dispatcher := http_client.NewDispatcher()
	handler := message_apid.NewMessageHandler()
	consumer := message_apid.NewConsumer(
		cfg.FifoPipe,
		buffer,
		dispatcher,
		cfg.UpdateFrequency,
		cfg.MaxCmdsPerUpdate,
		handler,
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

	errorChan := make(chan error)
	defer close(errorChan)

	// Spawn consumer to listen for messages
	go f.Consumer.Listen(errorChan)

	return <-errorChan
}
