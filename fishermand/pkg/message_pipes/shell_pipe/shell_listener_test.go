package shellpipe

import (
	"errors"
	"testing"
)

var (
	fifoPipe         = "/tmp/fakepipe"
	buffer           = NewBuffer()
	handler          = NewShellMessageHandler(buffer)
	errArbitrary     = errors.New("fake arbitrary error")
	msBetweenUpdates = int64(1000)
	maxCmdsPerUpdate = 5
)

func TestNewShellListener(t *testing.T) {
	// Arrange
	consumer := NewShellListener(fifoPipe, buffer, nil, msBetweenUpdates, maxCmdsPerUpdate, handler)

	// Assert
	if consumer.fifoPipe != fifoPipe {
		t.Error("Field fifoPipe is nil, should be populated")
	}
	if consumer.buffer != buffer {
		t.Error("Field buffer is nil, should be populated")
	}
}

func TestSetup_WhenNoExecError_NoError(t *testing.T) {
	// Arrange
	consumer := NewShellListener(fifoPipe, buffer, nil, msBetweenUpdates, maxCmdsPerUpdate, handler)

	// Act
	err := consumer.Setup()

	// Assert
	if err != nil {
		t.Errorf("Returned error from Setup, should have been nil. Error: %v", err)
	}
}

func TestSetup_WhenExecError_Error(t *testing.T) {
	// Arrange
	consumer := NewShellListener("", buffer, nil, msBetweenUpdates, maxCmdsPerUpdate, handler)

	// Act
	err := consumer.Setup()

	// Assert
	if err == nil {
		t.Error("Returned nil from Setup, should have been error")
	}
}
