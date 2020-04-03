package cmdpipeline

import (
	"os/exec"
	"strings"
	"time"

	"github.com/henrysdev/fisherman/pkg/client"
	"github.com/henrysdev/fisherman/pkg/common"
)

// ConsumerAPI provides an API for interacting with
// the command listener
type ConsumerAPI interface {
	Setup() error
	Listen()
	bytesToCommandRecord(cmd string) *common.CommandRecord
}

// Consumer represents the state of a command consumer
type Consumer struct {
	buffer           *Buffer
	fifoPipe         string
	client           *client.Dispatcher
	lastUpdateTime   *time.Time
	msBetweenUpdates int64
	maxCmdsPerUpdate int
}

// NewConsumer returns a new Consumer instance
func NewConsumer(
	fifoPipe string,
	buffer *Buffer,
	client *client.Dispatcher,
	msBetweenUpdates int64,
	maxCmdsPerUpdate int,
) *Consumer {
	currTime := time.Now()
	return &Consumer{
		fifoPipe:         fifoPipe,
		buffer:           buffer,
		client:           client,
		lastUpdateTime:   &currTime,
		msBetweenUpdates: msBetweenUpdates,
		maxCmdsPerUpdate: maxCmdsPerUpdate,
	}
}

// Setup is a method that sets up the consumer to be ready.
// Should be called immediately after instantiation
func (c *Consumer) Setup() error {
	exec.Command("rm", c.fifoPipe).Output()
	_, err := exec.Command("mkfifo", c.fifoPipe).Output()
	if err != nil {
		return err
	}
	return nil
}

// Listen continuously polls for new bash commands sent
// over a fifo pipe written to from the preexec hook.
// Send updates to server when appropriate.
func (c *Consumer) Listen(errorChan chan error) {
	for {
		resp, err := exec.Command("cat", c.fifoPipe).Output()
		if err != nil {
			errorChan <- err
			return
		}

		command := c.bytesToCommandRecord(resp)

		// Push command to buffered history
		c.buffer.PushCommand(command)

		// Check if command buffer is ready to push to server
		currTime := time.Now()
		elapsedMs := currTime.Sub(*c.lastUpdateTime).Nanoseconds() / 1000000
		if !c.buffer.IsEmpty() && elapsedMs > c.msBetweenUpdates {
			commands := c.buffer.Take(c.maxCmdsPerUpdate)
			c.client.SendCmdHistoryUpdate(commands)
			c.lastUpdateTime = &currTime
		}
	}
}

// Listen continuously polls for new bash commands sent
// over a fifo pipe written to from the preexec hook
func (c *Consumer) bytesToCommandRecord(cmdbytes []byte) *common.CommandRecord {
	// TODO return a Command datatype
	cmdStr := strings.TrimSpace(string(cmdbytes))
	timestamp := time.Now().UnixNano() / 1000000
	return &common.CommandRecord{
		Command:   cmdStr,
		Timestamp: timestamp,
	}
}
