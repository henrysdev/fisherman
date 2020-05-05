package message_apid

import (
	"errors"
	"testing"
	"time"
)

var (
	fifoPipe         = "/tmp/fakepipe"
	buffer           = NewBuffer()
	errArbitrary     = errors.New("fake arbitrary error")
	msBetweenUpdates = int64(1000)
	maxCmdsPerUpdate = 5
)

func TestNewConsumer(t *testing.T) {
	// Arrange
	consumer := NewConsumer(fifoPipe, buffer, nil, msBetweenUpdates, maxCmdsPerUpdate)

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
	consumer := NewConsumer(fifoPipe, buffer, nil, msBetweenUpdates, maxCmdsPerUpdate)

	// Act
	err := consumer.Setup()

	// Assert
	if err != nil {
		t.Errorf("Returned error from Setup, should have been nil. Error: %v", err)
	}
}

func TestSetup_WhenExecError_Error(t *testing.T) {
	// Arrange
	consumer := NewConsumer("", buffer, nil, msBetweenUpdates, maxCmdsPerUpdate)

	// Act
	err := consumer.Setup()

	// Assert
	if err == nil {
		t.Error("Returned nil from Setup, should have been error")
	}
}

func TestListen_WhenNoExecError_Continues(t *testing.T) {
	// Arrange
	errorChan := make(chan error)

	consumer := NewConsumer(fifoPipe, buffer, nil, msBetweenUpdates, maxCmdsPerUpdate)
	consumer.Setup()

	// Act
	go consumer.Listen(errorChan)
	go func() { errorChan <- errArbitrary }()
	errThatCausedExit := <-errorChan

	// Assert
	if errThatCausedExit != errArbitrary {
		t.Errorf("Expected error to be %v but got error %v", errArbitrary, errThatCausedExit)
	}
}

func TestListen_WhenExecError_Exits(t *testing.T) {
	// Arrange
	errorChan := make(chan error)
	defer close(errorChan)

	consumer := NewConsumer("", buffer, nil, msBetweenUpdates, maxCmdsPerUpdate)
	consumer.Setup()

	// Act
	go consumer.Listen(errorChan)
	go func() {
		time.AfterFunc(time.Second*1, func() { errorChan <- errArbitrary })
	}()
	errThatCausedExit := <-errorChan

	// Assert
	if errThatCausedExit == errArbitrary {
		t.Errorf("Expected error to not be %v", errArbitrary)
	}
}
