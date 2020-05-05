package messageapid

import (
	"fmt"
	"log"
	"strconv"
	"strings"
	"time"

	"github.com/henrysdev/fisherman/fishermand/pkg/common"
)

// HandlerAPI is an interface for dealing with validating, parsing, and routing IPC messages
// received from the shell processes pushing messages to the unix named pipe (FIFO pipe) that
// fishermand reads from.
type HandlerAPI interface {
	ProcessMessage(msgBytes []byte, buffer BufferAPI) error
	handleCommand(shellMessage *common.ShellMessage, buffer BufferAPI)
	handleStderr(shellMessage *common.ShellMessage, buffer BufferAPI)
}

// MessageHandler represents the state of the handler which includes a lookup table for
// PIDs (process ids) -> ShellProcess structs
type MessageHandler struct {
	shellProcesses map[string]*ShellProcess
}

// NewMessageHandler returns a new instance of a MessageHandler
func NewMessageHandler() *MessageHandler {
	return &MessageHandler{
		shellProcesses: make(map[string]*ShellProcess),
	}
}

// ProcessMessage validates and parses an IPC message into the appropriate structure and routes
// the message based on the message type
func (m *MessageHandler) ProcessMessage(msgBytes []byte, buffer BufferAPI) error {
	shellMessage, err := bytesToMessage(msgBytes)
	if err != nil {
		log.Println(common.ShellMessageFormatError(err.Error()))
		return nil
	}

	// Route message based on message type
	switch shellMessage.MessageType {
	case common.COMMAND:
		m.handleCommand(shellMessage, buffer)
		return nil
	case common.STDERR:
		m.handleStderr(shellMessage, buffer)
		return nil
	default:
		return common.ShellMessageFormatError(string(msgBytes))
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
		return nil, fmt.Errorf("Invalid message %s", msgStr)
	}
	msgType, err := strconv.Atoi(parts[1])
	if err != nil {
		return nil, err
	}
	shellMessage := &common.ShellMessage{
		PID:             parts[0],
		MessageType:     common.Messagetype(msgType),
		MessageContents: parts[2],
		Timestamp:       time.Now().UnixNano() / 1000000,
	}
	return shellMessage, nil
}

func (m *MessageHandler) handleCommand(
	shellMessage *common.ShellMessage,
	buffer BufferAPI,
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

func (m *MessageHandler) handleStderr(
	shellMessage *common.ShellMessage,
	buffer BufferAPI,
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
			buffer.PushExecutionRecord(record)
		}
	}
}
