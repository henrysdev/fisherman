package shellpipe

import (
	"fmt"
	"strconv"
	"strings"
	"time"

	common "github.com/henrysdev/fisherman/fishermand/pkg/common"
	messagepipes "github.com/henrysdev/fisherman/fishermand/pkg/message_pipes"
	"github.com/pkg/errors"
)

// ShellHandlerAPI is an interface for dealing with validating, parsing, and routing IPC messages
// received from the shell processes pushing messages to the unix named pipe (FIFO pipe) that
// fishermand reads from.
type ShellHandlerAPI interface {
	messagepipes.HandlerAPI
	handleCommand(shellMessage *common.ShellMessage)
	handleStderr(shellMessage *common.ShellMessage)
	handleExit(shellMessage *common.ShellMessage)
}

// ShellMessageHandler represents the state of the handler which includes a lookup table for
// PIDs (process ids) -> ShellProcess structs
type ShellMessageHandler struct {
	buffer         BufferAPI
	shellProcesses map[string]*ShellProcess
}

// NewShellMessageHandler returns a new instance of a ShellMessageHandler
func NewShellMessageHandler(buffer BufferAPI) *ShellMessageHandler {
	return &ShellMessageHandler{
		buffer:         buffer,
		shellProcesses: make(map[string]*ShellProcess),
	}
}

// ProcessMessage validates and parses an IPC message into the appropriate structure and routes
// the message based on the message type
func (m *ShellMessageHandler) ProcessMessage(msgBytes []byte) error {
	shellMessage, err := bytesToMessage(msgBytes)
	if err != nil {
		return errors.Wrap(err, "shell message handler error during process message")
	}
	// Route message based on message type
	switch shellMessage.MessageType {
	case common.COMMAND:
		m.handleCommand(shellMessage)
		return nil
	case common.STDERR:
		m.handleStderr(shellMessage)
		return nil
	case common.EXIT:
		m.handleExit(shellMessage)
		return nil
	default:
		return fmt.Errorf("invalid shell message type: %v for shell message %v",
			shellMessage.MessageType,
			shellMessage)
	}
}

// Validate message structure and read into ShellMessage struct
func bytesToMessage(msgBytes []byte) (*common.ShellMessage, error) {
	msgStr := strings.TrimSpace(string(msgBytes))
	parts := strings.SplitN(msgStr, " ", 3)

	// Handle case where message content is empty
	if len(parts) == 2 {
		parts = append(parts, "")
	}
	if len(parts) != 3 {
		return nil, fmt.Errorf("invalid message %s", msgStr)
	}
	msgType, err := strconv.Atoi(parts[1])
	if err != nil {
		return nil, errors.Wrap(err, "shell message handler error during strconv messagetype")
	}
	shellMessage := &common.ShellMessage{
		PID:             parts[0],
		MessageType:     common.Messagetype(msgType),
		MessageContents: parts[2],
		Timestamp:       time.Now().UnixNano() / 1000000,
	}
	return shellMessage, nil
}

func (m *ShellMessageHandler) handleCommand(
	shellMessage *common.ShellMessage,
) {
	pid := shellMessage.PID
	command := &common.Command{
		Line:      shellMessage.MessageContents,
		Timestamp: shellMessage.Timestamp,
	}
	// If a shell process exists for the given pid, add the command. Otherwise, instantiate a
	// new shell process struct for this pid
	if _, found := m.shellProcesses[pid]; found {
		m.shellProcesses[pid].PushCommand(command)
	} else {
		m.shellProcesses[pid] = NewShellProcess(pid, command)
	}
}

func (m *ShellMessageHandler) handleStderr(
	shellMessage *common.ShellMessage,
) {
	pid := shellMessage.PID
	stderr := &common.Stderr{
		Line:      shellMessage.MessageContents,
		Timestamp: shellMessage.Timestamp,
	}
	// Finish building a new execution record for a given shell given that we have both a command
	// and its corresponding error
	if _, found := m.shellProcesses[pid]; found {
		if record := m.shellProcesses[pid].PushStderr(stderr); record != nil {
			m.buffer.PushExecutionRecord(record)
		}
	}
}

func (m *ShellMessageHandler) handleExit(
	shellMessage *common.ShellMessage,
) {
	pid := shellMessage.PID
	exitSignal := &common.ExitSignal{
		Info:      shellMessage.MessageContents,
		Timestamp: shellMessage.Timestamp,
	}
	// Push exitSignal message, signaling the end of life for the shell process at the given pid.
	// Delete the pid key from the map to prevent potential pid collisions in the future
	if _, found := m.shellProcesses[pid]; found {
		if record := m.shellProcesses[pid].PushExitSignal(exitSignal); record != nil {
			m.buffer.PushExecutionRecord(record)
			if _, ok := m.shellProcesses[pid]; ok {
				delete(m.shellProcesses, pid)
			}
		}
	}
}
