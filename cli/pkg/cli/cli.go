package cli

import (
	"fmt"

	"github.com/henrysdev/fisherman/client/pkg/client"
)

// ClientAPI provides the API for interacting with the fisherman daemon process
type ClientAPI interface {
	Start() error
	Stop() error
	Restart() error
}

// CLI holds the state of the CLI
type CLI struct {
	FifoPipe string
}

// Start begins the daemon if it is not already started
func (c *CLI) Start() error {
	fmt.Println("Starting...")
	if client.FileExists(c.FifoPipe) {
		return fmt.Errorf("Failed to start: fishermand is already running")
	}
	// TODO execute binary
	fmt.Println("fishermand started successfully")
	return nil
}

// Stop terminates the daemon if it is already running
func (c *CLI) Stop() error {
	fmt.Println("Stopping...")
	if !client.FileExists(c.FifoPipe) {
		return fmt.Errorf("Failed to stop: fishermand is not running")
	}
	// TODO send message to FIFO pipe telling it to shut down
	fmt.Println("fishermand stopped successfully")
	return nil
}

// Restart terminates the daemon and then starts it
func (c *CLI) Restart() error {
	fmt.Println("Restarting...")
	// TODO send message to FIFO pipe telling it to restart
	fmt.Println("fishermand restarted successfully")
	return nil
}
