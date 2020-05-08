package shellpipe

import (
	"os/exec"
	"time"

	"github.com/pkg/errors"

	httpclient "github.com/henrysdev/fisherman/fishermand/pkg/http_client"
	messagepipes "github.com/henrysdev/fisherman/fishermand/pkg/message_pipes"
)

// ShellListener represents the state of a command consumer
type ShellListener struct {
	buffer           BufferAPI
	fifoPipe         string
	client           httpclient.DispatchAPI
	lastUpdateTime   *time.Time
	msBetweenUpdates int64
	maxCmdsPerUpdate int
	handler          messagepipes.HandlerAPI
}

// NewShellListener returns a new ShellListener instance
func NewShellListener(
	fifoPipe string,
	buffer BufferAPI,
	client httpclient.DispatchAPI,
	msBetweenUpdates int64,
	maxCmdsPerUpdate int,
	handler messagepipes.HandlerAPI,
) *ShellListener {
	currTime := time.Now()
	return &ShellListener{
		fifoPipe:         fifoPipe,
		buffer:           buffer,
		client:           client,
		lastUpdateTime:   &currTime,
		msBetweenUpdates: msBetweenUpdates,
		maxCmdsPerUpdate: maxCmdsPerUpdate,
		handler:          handler,
	}
}

// Setup is a method that sets up the consumer to be ready. Should be called immediately
// after instantiation
func (c *ShellListener) Setup() error {
	exec.Command("rm", c.fifoPipe).Output()
	_, err := exec.Command("mkfifo", c.fifoPipe).Output()
	if err != nil {
		return errors.Wrap(err, "shell listener setup failed")
	}
	return nil
}

// Listen continuously polls for new IPC messages sent over a fifo pipe written to from local
// shell processes and the CLI. Send updates to server when appropriate.
func (c *ShellListener) Listen() error {
	for {
		resp, err := exec.Command("cat", c.fifoPipe).Output()
		if err != nil {
			return errors.Wrap(err, "shell listener failed to read pipe")
		}

		err = c.handler.ProcessMessage(resp)
		if err != nil {
			return errors.Wrap(err, "shell listener failed to process message")
		}

		// Check if command buffer is ready to push to server
		currTime := time.Now()
		elapsedMs := currTime.Sub(*c.lastUpdateTime).Nanoseconds() / 1000000
		if !c.buffer.IsEmpty() && elapsedMs > c.msBetweenUpdates {
			commands := c.buffer.TakeN(c.maxCmdsPerUpdate)
			c.client.SendCmdHistoryUpdate(commands)
			c.lastUpdateTime = &currTime
		}
	}
}
