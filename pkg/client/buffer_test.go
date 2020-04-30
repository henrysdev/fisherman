package client

import (
	"testing"
	"time"
)

var (
	testcmd = &CommandRecord{
		Command:   "f_)*ake command//",
		Timestamp: time.Now().UnixNano() / 1000000,
	}
)

func TestNewBuffer(t *testing.T) {
	// Arrange
	buffer := NewBuffer()

	// Assert
	if len(buffer.commands) != 0 {
		t.Error("Buffer is not equivalent to an empty buffer object")
	}
}

func TestPushCommand(t *testing.T) {
	// Arrange
	buffer := NewBuffer()

	// Act
	buffer.PushCommand(testcmd)
	if len(buffer.commands) != 1 {
		t.Error("Buffer commands should be of size 1")
	}
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)

	// Assert
	if len(buffer.commands) != 4 {
		t.Error("Buffer commands should be of size 4")
	}
}

func TestTake_WhenInbounds(t *testing.T) {
	// Arrange
	buffer := NewBuffer()

	// Act
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)
	cmds := buffer.Take(3)

	// Assert
	if len(cmds) != 3 {
		t.Error("Returned commands should be of size 3")
	}
	if len(buffer.commands) != 1 {
		t.Error("Buffer commands should be of size 1")
	}
}

func TestTake_WhenUnderbounds(t *testing.T) {
	// Arrange
	buffer := NewBuffer()

	// Act
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)
	cmds := buffer.Take(-99)

	// Assert
	if len(cmds) != 0 {
		t.Error("Returned commands should be of size 0")
	}
}

func TestTake_WhenOverbounds(t *testing.T) {
	// Arrange
	buffer := NewBuffer()

	// Act
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)
	buffer.PushCommand(testcmd)
	cmds := buffer.Take(999)

	// Assert
	if len(cmds) != 4 {
		t.Error("Returned commands should be of size 4")
	}
}
