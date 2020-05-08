package systempipe

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/henrysdev/fisherman/fishermand/pkg/common"
	messagepipes "github.com/henrysdev/fisherman/fishermand/pkg/message_pipes"
	"github.com/pkg/errors"
)

// SystemHandlerAPI provides an interface for handling message for system pipe
type SystemHandlerAPI interface {
	messagepipes.HandlerAPI
	handleStop(systemMessage *common.SystemMessage) error
}

// SystemMessageHandler represents the state of the handler which includes a lookup table for
type SystemMessageHandler struct {
}

// NewSystemMessageHandler returns a new instance of a SystemMessageHandler
func NewSystemMessageHandler() *SystemMessageHandler {
	return &SystemMessageHandler{}
}

// ProcessMessage validates and parses an IPC message into the appropriate structure and routes
// the message based on the message type
func (m *SystemMessageHandler) ProcessMessage(msgBytes []byte) error {
	systemMessage, err := bytesToMessage(msgBytes)
	if err != nil {
		return errors.Wrap(err, "system message handler error on process message")
	}

	switch systemMessage.MessageType {
	case common.STOP:
		return m.handleStop(systemMessage)
	default:
		return fmt.Errorf("system message handler error invalid messagetype")
	}
}

// Validate message structure and read into ShellMessage struct
func bytesToMessage(msgBytes []byte) (*common.SystemMessage, error) {
	msgStr := strings.TrimSpace(string(msgBytes))
	if len(msgStr) < 1 {
		return nil, fmt.Errorf("invalid message %s", msgStr)
	}
	msgType, err := strconv.Atoi(msgStr[:1])
	if err != nil {
		return nil, errors.Wrap(err, "system message handler error on messagetype strconv")
	}

	systemMessage := &common.SystemMessage{
		MessageType: common.Messagetype(msgType),
	}
	return systemMessage, nil
}

func (m *SystemMessageHandler) handleStop(systemMessage *common.SystemMessage) error {
	return nil
}
