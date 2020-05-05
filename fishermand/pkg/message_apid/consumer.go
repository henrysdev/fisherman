package messageapid

import (
	"os/exec"
	"time"

	httpclient "github.com/henrysdev/fisherman/fishermand/pkg/http_client"
)

// ConsumerAPI allows for interacting with the message listener. The consumer works by
// pulling from the read end of a unix named pipe (FIFO pipe) that messages are written to by
// both local shell processes as well as the accompanying fisherman CLI tool. These messages are
// handled to the MessageHandler and then queued in the Buffer before being dispatched by the
// http Client.
type ConsumerAPI interface {
	Setup() error
	Listen(errorChan chan error)
}

// Consumer represents the state of a command consumer
type Consumer struct {
	buffer           BufferAPI
	fifoPipe         string
	client           httpclient.DispatchAPI
	lastUpdateTime   *time.Time
	msBetweenUpdates int64
	maxCmdsPerUpdate int
	handler          HandlerAPI
}

// NewConsumer returns a new Consumer instance
func NewConsumer(
	fifoPipe string,
	buffer BufferAPI,
	client httpclient.DispatchAPI,
	msBetweenUpdates int64,
	maxCmdsPerUpdate int,
	handler HandlerAPI,
) *Consumer {
	currTime := time.Now()
	return &Consumer{
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
func (c *Consumer) Setup() error {
	exec.Command("rm", c.fifoPipe).Output()
	_, err := exec.Command("mkfifo", c.fifoPipe).Output()
	if err != nil {
		return err
	}
	return nil
}

// Listen continuously polls for new IPC messages sent over a fifo pipe written to from local
// shell processes and the CLI. Send updates to server when appropriate.
func (c *Consumer) Listen(errorChan chan error) {
	for {
		resp, err := exec.Command("cat", c.fifoPipe).Output()
		if err != nil {
			errorChan <- err
			return
		}

		err = c.handler.ProcessMessage(resp, c.buffer)
		if err != nil {
			errorChan <- err
			return
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
