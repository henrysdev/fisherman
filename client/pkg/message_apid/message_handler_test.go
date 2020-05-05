package message_apid

import (
	"testing"
)

func TestProcessMessage(t *testing.T) {
	// Arrange
	handler := NewMessageHandler()
	cmdMsg := []byte(`100 0 ls -gha`)
	stderrMsg := []byte(`100 1 runtime error //\/\`)
	buffer := NewBuffer()

	// Act
	cmdErr := handler.ProcessMessage(cmdMsg, buffer)
	stderrErr := handler.ProcessMessage(stderrMsg, buffer)

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
	handler := NewMessageHandler()
	cmdMsg := []byte(`100 0 ls -gha`)
	stderrMsg := []byte(`100 1`)
	buffer := NewBuffer()

	// Act
	cmdErr := handler.ProcessMessage(cmdMsg, buffer)
	stderrErr := handler.ProcessMessage(stderrMsg, buffer)

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
	handler := NewMessageHandler()
	cmdMsg := []byte(`100 0 ls -gha`)
	stderrMsg := []byte(`100 1`)
	buffer := NewBuffer()

	// Act
	stderrErr := handler.ProcessMessage(stderrMsg, buffer)
	cmdErr := handler.ProcessMessage(cmdMsg, buffer)

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
