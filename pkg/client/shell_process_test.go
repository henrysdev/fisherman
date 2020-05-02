package client

import (
	"testing"
	"time"
)

var (
	pid     = "1234"
	command = &Command{
		Line:      "abc123",
		Timestamp: time.Now().UnixNano() / 1000000,
	}
)

func TestNewShellProcess(t *testing.T) {
	// Arrange
	shellProcess := NewShellProcess(pid, command)

	// Assert
	if shellProcess.PID != pid {
		t.Error("Field pid should be equal to expected")
	}
	if shellProcess.Command != command {
		t.Error("Field command should be equal to expected")
	}
}

func TestPushStderr(t *testing.T) {
	// Arrange
	stderr := &Stderr{
		Line:      "err output",
		Timestamp: time.Now().UnixNano() / 1000000,
	}
	expectedRecord := &ExecutionRecord{
		Command: command,
		Stderr:  stderr,
	}
	shellProcess := NewShellProcess(pid, command)

	// Act
	record := shellProcess.PushStderr(stderr)

	// Assert
	if expectedRecord.Command != record.Command {
		t.Error("record command should be equal to expected record command")
	}
	if expectedRecord.Stderr != record.Stderr {
		t.Error("record stderr should be equal to expected record stderr")
	}
	if shellProcess.Command != nil {
		t.Error("Field `command` should've be cleared")
	}
	if shellProcess.Stderr != nil {
		t.Error("Field `stderr` should've be cleared")
	}
}

func TestPushStderr_WhenNilCommand_Nil(t *testing.T) {
	// Arrange
	stderr := &Stderr{
		Line:      "err output",
		Timestamp: time.Now().UnixNano() / 1000000,
	}
	shellProcess := NewShellProcess(pid, nil)

	// Act
	record := shellProcess.PushStderr(stderr)

	// Assert
	if record != nil {
		t.Error("expected record to be nil")
	}
}

// // ShellProcessAPI exposes an API for interacting with shell process state
// type ShellProcessAPI interface {
// 	PushCommand(command *Command)
// 	PushStderror(stderr *Stderr) *ExecutionRecord
// }

// // ShellProcess represents the state of a shell the program receives messages from
// type ShellProcess struct {
// 	PID     string
// 	Command *Command
// 	Stderr  *Stderr
// }

// // NewShellProcess returns a new ShellProcess instance
// func NewShellProcess(pid string, command *Command) *ShellProcess {
// 	return &ShellProcess{
// 		PID:     pid,
// 		Command: command,
// 	}
// }

// // PushCommand stores the command
// func (s *ShellProcess) PushCommand(command *Command) {
// 	s.Command = command
// }

// // PushStderr stores the command and return an execution record
// func (s *ShellProcess) PushStderr(stderr *Stderr) *ExecutionRecord {
// 	if s.Command == nil {
// 		return nil
// 	}
// 	record := &ExecutionRecord{
// 		Command: s.Command,
// 		Stderr:  stderr,
// 	}
// 	s.Command = nil
// 	s.Stderr = nil
// 	return record
// }
