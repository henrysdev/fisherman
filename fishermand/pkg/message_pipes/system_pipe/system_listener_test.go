package systempipe

import (
	"errors"
	"testing"
)

var (
	fifoPipe         = "/tmp/fakepipe"
	handler          = NewSystemMessageHandler(func(reason interface{}) {})
	errArbitrary     = errors.New("fake arbitrary error")
	msBetweenUpdates = int64(1000)
	maxCmdsPerUpdate = 5
)

func TestNewSystemListener(t *testing.T) {
	// Arrange
	consumer := NewSystemListener(fifoPipe, handler)

	// Assert
	if consumer.fifoPipe != fifoPipe {
		t.Error("Field fifoPipe is nil, should be populated")
	}
}

func TestSetup_WhenNoExecError_NoError(t *testing.T) {
	// Arrange
	consumer := NewSystemListener(fifoPipe, handler)

	// Act
	err := consumer.Setup()

	// Assert
	if err != nil {
		t.Errorf("Returned error from Setup, should have been nil. Error: %v", err)
	}
}

func TestSetup_WhenExecError_Error(t *testing.T) {
	// Arrange
	consumer := NewSystemListener("", handler)

	// Act
	err := consumer.Setup()

	// Assert
	if err == nil {
		t.Error("Returned nil from Setup, should have been error")
	}
}
