package shellpipe

import (
	common "github.com/henrysdev/fisherman/fishermand/pkg/common"
)

// ShellProcessAPI exposes an API for interacting with shell process state
type ShellProcessAPI interface {
	PushCommand(command *common.Command)
	PushStderror(stderr *common.Stderr) *common.ExecutionRecord
	PushExitSignal(exitSignal *common.ExitSignal) *common.ExecutionRecord
}

// ShellProcess represents the state of a shell the program receives messages from
type ShellProcess struct {
	PID        string
	NextRecord *common.ExecutionRecord
}

// NewShellProcess returns a new ShellProcess instance
func NewShellProcess(pid string, command *common.Command) *ShellProcess {
	return &ShellProcess{
		PID: pid,
		NextRecord: &common.ExecutionRecord{
			Command: command,
		},
	}
}

// PushCommand stores the command
func (s *ShellProcess) PushCommand(command *common.Command) {
	s.NextRecord.Command = command
}

// PushStderr stores the stderr and returns an execution record
func (s *ShellProcess) PushStderr(stderr *common.Stderr) *common.ExecutionRecord {
	if s.NextRecord.Command == nil {
		return nil
	}
	record := &common.ExecutionRecord{
		PID:     s.PID,
		Command: s.NextRecord.Command,
	}
	// Only set stderr is there was actual error content
	if stderr.Line != "" {
		record.Stderr = stderr
	}
	s.NextRecord.Command = nil
	s.NextRecord.Stderr = nil
	return record
}

// PushExitSignal stores the stderr and returns an execution record
func (s *ShellProcess) PushExitSignal(exitSignal *common.ExitSignal) *common.ExecutionRecord {
	return &common.ExecutionRecord{
		PID:        s.PID,
		ExitSignal: exitSignal,
	}
}
