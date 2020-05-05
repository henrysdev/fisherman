package cli

import (
	"fmt"
	"os/exec"

	"github.com/henrysdev/fisherman/fishermand/pkg/utils"
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
	if utils.FileExists(c.FifoPipe) {
		return fmt.Errorf("Failed to start: fishermand is already running")
	}
	// TODO point to /usr/bin/fisherman...
	cmd := exec.Command("go", "run", "/Users/henry.warren/go/src/github.com/henrysdev/fisherman/client/cmd/fishermand/main.go")
	cmd.Start()
	fmt.Println(cmd.Process.Pid)
	fmt.Println("fishermand started successfully")
	return nil
}

// Stop terminates the daemon if it is already running
func (c *CLI) Stop() error {
	fmt.Println("Stopping...")
	if !utils.FileExists(c.FifoPipe) {
		return fmt.Errorf("Failed to stop: fishermand is not running")
	}
	// TODO send message to FIFO pipe telling it to shut down
	fmt.Println("fishermand stopped successfully")
	return nil
}

// Restart terminates the daemon and then restarts it
func (c *CLI) Restart() error {
	fmt.Println("Restarting...")
	if utils.FileExists(c.FifoPipe) {
		// TODO send message to FIFO pipe telling it to restart
	} else {
		c.Start()
	}

	fmt.Println("fishermand restarted successfully")
	return nil
}
