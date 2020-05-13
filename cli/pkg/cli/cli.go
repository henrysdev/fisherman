package cli

import (
	"fmt"
	"log"
	"os/exec"

	"github.com/henrysdev/fisherman/fishermand/pkg/utils"
)

// ClientAPI provides the API for interacting with the fisherman daemon process
type ClientAPI interface {
	Start()
	Stop()
	Restart()
}

// CLI holds the state of the CLI
type CLI struct {
	ShellPipe   string
	SystemPipe  string
	BinLocation string
}

// Start begins the daemon if it is not already started
func (c *CLI) Start() {
	log.Println("Starting...")
	if utils.FileExists(c.ShellPipe) {
		log.Println("fishermand is already running")
		return
	}
	_, err := exec.Command(c.BinLocation).Output()
	if err != nil {
		log.Fatal(err)
		return
	}
	log.Println("fishermand started successfully")
}

// Stop terminates the daemon if it is already running
func (c *CLI) Stop() {
	log.Println("Stopping...")
	if !utils.FileExists(c.ShellPipe) {
		log.Println("fishermand is not running")
		return
	}
	message := fmt.Sprintf("echo 2 > %s", c.SystemPipe)
	_, err := exec.Command("bash", "-c", message).Output()
	if err != nil {
		log.Fatal(err)
		return
	}

	log.Println("fishermand stopped successfully")
}

// Restart terminates the daemon and then restarts it
func (c *CLI) Restart() {
	log.Println("Restarting...")
	c.Stop()
	c.Start()
	log.Println("fishermand restarted successfully")
}
