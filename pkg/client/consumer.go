package client

import (
	"fmt"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

// ConsumerAPI provides an API for interacting with the command listener
type ConsumerAPI interface {
	Setup() error
	Listen()
	processShellMessage(msgBytes []byte) error
}

// Consumer represents the state of a command consumer
type Consumer struct {
	buffer           *Buffer
	fifoPipe         string
	client           *Dispatcher
	lastUpdateTime   *time.Time
	msBetweenUpdates int64
	maxCmdsPerUpdate int
	shellProcesses   map[string]*ShellProcess
}

// NewConsumer returns a new Consumer instance
func NewConsumer(
	fifoPipe string,
	buffer *Buffer,
	client *Dispatcher,
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
		shellProcesses:   make(map[string]*ShellProcess),
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

// Listen continuously polls for new bash commands sent over a fifo pipe written to from the
// preexec hook. Send updates to server when appropriate.
func (c *Consumer) Listen(errorChan chan error) {
	for {
		resp, err := exec.Command("cat", c.fifoPipe).Output()
		if err != nil {
			errorChan <- err
			return
		}

		err = c.processShellMessage(resp)
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

func (c *Consumer) processShellMessage(msgBytes []byte) error {
	shellMessage, err := bytesToMessage(msgBytes)
	if err != nil {
		fmt.Println(ShellMessageFormatError(err.Error()))
		return nil
	}

	// Route message based on message type
	pid := shellMessage.PID
	switch shellMessage.MessageType {
	case COMMAND:
		command := &Command{
			Line:      shellMessage.MessageContents,
			Timestamp: shellMessage.Timestamp,
		}
		if _, found := c.shellProcesses[pid]; found {
			c.shellProcesses[pid].PushCommand(command)
		} else {
			c.shellProcesses[pid] = NewShellProcess(pid, command)
		}
		return nil
	case STDERR:
		stderr := &Stderr{
			Line:      shellMessage.MessageContents,
			Timestamp: shellMessage.Timestamp,
		}
		if _, found := c.shellProcesses[pid]; found {
			if record := c.shellProcesses[pid].PushStderr(stderr); record != nil {
				c.buffer.PushExecutionRecord(record)
			}
		}
		return nil
	default:
		return ShellMessageFormatError(string(msgBytes))
	}
}

// Validate message structure and read into ShellMessage struct
func bytesToMessage(msgBytes []byte) (*ShellMessage, error) {
	msgStr := strings.TrimSpace(string(msgBytes))
	parts := strings.SplitN(msgStr, " ", 3)

	// Handle case where message content is empty
	if len(parts) == 2 {
		parts = append(parts, "")
	}
	if len(parts) != 3 {
		return nil, fmt.Errorf("Invalid message %s", msgStr)
	}
	msgType, err := strconv.Atoi(parts[1])
	if err != nil {
		return nil, err
	}
	shellMessage := &ShellMessage{
		PID:             parts[0],
		MessageType:     messagetype(msgType),
		MessageContents: parts[2],
		Timestamp:       time.Now().UnixNano() / 1000000,
	}

	return shellMessage, nil
}
