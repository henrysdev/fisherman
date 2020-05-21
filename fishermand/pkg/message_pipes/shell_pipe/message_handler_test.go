package shellpipe

import (
	"testing"
)

func TestProcessMessage(t *testing.T) {
	// Arrange
	buffer := NewBuffer()
	handler := NewShellMessageHandler(buffer)
	cmdMsg := []byte(`100 0 ls -gha`)
	stderrMsg := []byte(`100 1 runtime error //\/\`)

	// Act
	cmdErr := handler.ProcessMessage(cmdMsg)
	stderrErr := handler.ProcessMessage(stderrMsg)

	// Assert
	if cmdErr != nil {
		t.Errorf("Returned error from ProcessMessage, should have been nil. Error: %v", cmdErr)
	}
	if stderrErr != nil {
		t.Errorf("Returned error from ProcessMessage, should have been nil. Error: %v", stderrErr)
	}
	if buffer.IsEmpty() {
		t.Errorf("Buffer should not be empty")
	}
}

func TestProcessMessage_EmptyError_ShouldStillPush(t *testing.T) {
	// Arrange
	buffer := NewBuffer()
	handler := NewShellMessageHandler(buffer)
	cmdMsg := []byte(`100 0 ls -gha`)
	stderrMsg := []byte(`100 1`)

	// Act
	cmdErr := handler.ProcessMessage(cmdMsg)
	stderrErr := handler.ProcessMessage(stderrMsg)

	// Assert
	if cmdErr != nil {
		t.Errorf("Returned error from ProcessMessage, should have been nil. Error: %v", cmdErr)
	}
	if stderrErr != nil {
		t.Errorf("Returned error from ProcessMessage, should have been nil. Error: %v", stderrErr)
	}
	if buffer.IsEmpty() {
		t.Errorf("Buffer should not be empty")
	}
}

func TestProcessMessage_ErrorFirst_ShouldNotPush(t *testing.T) {
	// Arrange
	buffer := NewBuffer()
	handler := NewShellMessageHandler(buffer)
	cmdMsg := []byte(`100 0 ls -gha`)
	stderrMsg := []byte(`100 1`)

	// Act
	stderrErr := handler.ProcessMessage(stderrMsg)
	cmdErr := handler.ProcessMessage(cmdMsg)

	// Assert
	if cmdErr != nil {
		t.Errorf("Returned error from ProcessMessage, should have been nil. Error: %v", cmdErr)
	}
	if stderrErr != nil {
		t.Errorf("Returned error from ProcessMessage, should have been nil. Error: %v", stderrErr)
	}
	if !buffer.IsEmpty() {
		t.Errorf("Buffer should not be empty")
	}
}

func TestProcessMessage_ExitMessage_ShouldPush(t *testing.T) {
	// Arrange
	buffer := NewBuffer()
	handler := NewShellMessageHandler(buffer)
	cmdMsg := []byte(`100 0 ls -gha`)
	exitMsg := []byte(`100 2 ls -gha`)

	// Act
	cmdErr := handler.ProcessMessage(cmdMsg)
	exitErr := handler.ProcessMessage(exitMsg)

	// Assert
	if cmdErr != nil {
		t.Errorf("Returned error from ProcessMessage, should have been nil. Error: %v", cmdErr)
	}
	if exitErr != nil {
		t.Errorf("Returned error from ProcessMessage, should have been nil. Error: %v", exitErr)
	}
	if buffer.IsEmpty() {
		t.Errorf("Buffer should not be empty")
	}
}
