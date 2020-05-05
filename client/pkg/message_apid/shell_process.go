package message_apid

import (
	"github.com/henrysdev/fisherman/client/pkg/common"
)

// ShellProcessAPI exposes an API for interacting with shell process state
type ShellProcessAPI interface {
	PushCommand(command *common.Command)
	PushStderror(stderr *common.Stderr) *common.ExecutionRecord
}

// ShellProcess represents the state of a shell the program receives messages from
type ShellProcess struct {
	PID     string
	Command *common.Command
	Stderr  *common.Stderr
}

// NewShellProcess returns a new ShellProcess instance
func NewShellProcess(pid string, command *common.Command) *ShellProcess {
	return &ShellProcess{
		PID:     pid,
		Command: command,
	}
}

// PushCommand stores the command
func (s *ShellProcess) PushCommand(command *common.Command) {
	s.Command = command
}

// PushStderr stores the command and return an execution record
func (s *ShellProcess) PushStderr(stderr *common.Stderr) *common.ExecutionRecord {
	if s.Command == nil {
		return nil
	}
	record := &common.ExecutionRecord{
		Command: s.Command,
		Stderr:  stderr,
	}
	s.Command = nil
	s.Stderr = nil
	return record
}
