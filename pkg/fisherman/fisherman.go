package fisherman

import (
	"fmt"
	"time"

	"github.com/pkg/errors"

	"github.com/henrysdev/fisherman/pkg/config"
	"github.com/henrysdev/fisherman/pkg/poller"
)

// API for interacting with Fisherman
type API interface {
	Init() error
	StartPolling() error
	StopPolling() error
	/*
		ViewHistory() (History, error)
		ViewTimeline() (Timeline, error)
	*/
}

// Fisherman contains necessary data for top level API methods
type Fisherman struct {
	Config *config.Config
	Poller *poller.Poller
}

// NewFisherman returns an instantiated Fisherman struct
func NewFisherman(cfg *config.Config) *Fisherman {
	return &Fisherman{
		Config: cfg,
		// TODO have a find seekPos function (wont always be 0!)
		Poller: poller.NewPoller(cfg.HistoryFile, 0),
	}
}

// StartPolling sends message to start continuously polling for changes on the fish history file
func (f *Fisherman) StartPolling() error {
	for {
		records, err := f.Poller.Poll()
		if err != nil {
			return errors.Wrap(err, "StartPolling failed")
		}
		fmt.Println("records: ", records)
		time.Sleep(time.Duration(f.Config.PollRate) * time.Millisecond)
	}
	return nil
}

// StopPolling sends message to stop polling for changes on the fish history file
func (f *Fisherman) StopPolling() error {
	fmt.Println("StopPolling Called!")
	return nil
}
