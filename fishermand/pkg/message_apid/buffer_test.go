package messageapid

import (
	"testing"
	"time"

	"github.com/henrysdev/fisherman/fishermand/pkg/common"
)

var (
	testrecord = &common.ExecutionRecord{
		Command: &common.Command{
			Line:      "f_)*ake command//",
			Timestamp: time.Now().UnixNano() / 1000000,
		},
		Stderr: &common.Stderr{
			Line:      "f_)*ake command//",
			Timestamp: time.Now().UnixNano() / 1000000,
		},
	}
)

func TestNewBuffer(t *testing.T) {
	// Arrange
	buffer := NewBuffer()

	// Assert
	if len(buffer.elements) != 0 {
		t.Error("Buffer is not equivalent to an empty buffer object")
	}
}

func TestPushExecutionRecord(t *testing.T) {
	// Arrange
	buffer := NewBuffer()

	// Act
	buffer.PushExecutionRecord(testrecord)
	if len(buffer.elements) != 1 {
		t.Error("Buffer commands should be of size 1")
	}
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)

	// Assert
	if len(buffer.elements) != 4 {
		t.Error("Buffer commands should be of size 4")
	}
}

func TestTake_WhenInbounds(t *testing.T) {
	// Arrange
	buffer := NewBuffer()

	// Act
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)
	cmds := buffer.TakeN(3)

	// Assert
	if len(cmds) != 3 {
		t.Error("Returned commands should be of size 3")
	}
	if len(buffer.elements) != 1 {
		t.Error("Buffer commands should be of size 1")
	}
}

func TestTake_WhenUnderbounds(t *testing.T) {
	// Arrange
	buffer := NewBuffer()

	// Act
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)
	cmds := buffer.TakeN(-99)

	// Assert
	if len(cmds) != 0 {
		t.Error("Returned commands should be of size 0")
	}
}

func TestTake_WhenOverbounds(t *testing.T) {
	// Arrange
	buffer := NewBuffer()

	// Act
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)
	buffer.PushExecutionRecord(testrecord)
	cmds := buffer.TakeN(999)

	// Assert
	if len(cmds) != 4 {
		t.Error("Returned commands should be of size 4")
	}
}
