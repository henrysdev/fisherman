package shellpipe

import (
	"testing"
	"time"

	"github.com/henrysdev/fisherman/fishermand/pkg/common"
)

var (
	pid     = "1234"
	command = &common.Command{
		Line:      "abc123",
		Timestamp: time.Now().UnixNano() / 1000000,
	}
	stderr = &common.Stderr{
		Line:      "err output",
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
	if shellProcess.NextRecord.Command != command {
		t.Error("Field command should be equal to expected")
	}
}

func TestPushStderr(t *testing.T) {
	// Arrange
	expectedRecord := &common.ExecutionRecord{
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
	if shellProcess.NextRecord.Command != nil {
		t.Error("Field `command` should've be cleared")
	}
	if shellProcess.NextRecord.Stderr != nil {
		t.Error("Field `stderr` should've be cleared")
	}
}

func TestPushStderr_WhenNilCommand_Nil(t *testing.T) {
	// Arrange
	shellProcess := NewShellProcess(pid, nil)

	// Act
	record := shellProcess.PushStderr(stderr)

	// Assert
	if record != nil {
		t.Error("expected record to be nil")
	}
}

func TestPushStderr_WhenEmptyStderr_NoStderr(t *testing.T) {
	// Arrange
	emptyStderr := &common.Stderr{
		Line:      "",
		Timestamp: time.Now().UnixNano() / 1000000,
	}
	expectedRecord := &common.ExecutionRecord{
		Command: command,
		Stderr:  nil,
	}
	shellProcess := NewShellProcess(pid, command)

	// Act
	record := shellProcess.PushStderr(emptyStderr)

	// Assert
	if expectedRecord.Command != record.Command {
		t.Error("record command should be equal to expected record command")
	}
	if expectedRecord.Stderr != nil {
		t.Error("record stderr should be nil")
	}
	if shellProcess.NextRecord.Command != nil {
		t.Error("Field `command` should've be cleared")
	}
	if shellProcess.NextRecord.Stderr != nil {
		t.Error("Field `stderr` should've be cleared")
	}
}

func TestPushExit_Record(t *testing.T) {
	// Arrange
	exitSignal := &common.ExitSignal{
		Info:      "exit info",
		Timestamp: time.Now().UnixNano() / 1000000,
	}
	shellProcess := NewShellProcess(pid, nil)

	// Act
	record := shellProcess.PushExitSignal(exitSignal)

	// Assert
	if record == nil {
		t.Error("expected record to not be nil")
	}
}
