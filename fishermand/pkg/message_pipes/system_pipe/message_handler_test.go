package systempipe

import (
	"testing"
)

func TestProcessMessage(t *testing.T) {
	// Arrange
	handler := NewSystemMessageHandler()
	stopMsg := []byte(`2`)

	// Act
	stopErr := handler.ProcessMessage(stopMsg)

	// Assert
	if stopErr != nil {
		t.Errorf("Returned error %v from ProcessMessage, should have been nil", stopErr)
	}
}

func TestProcessMessage_WhenInvalid_Error(t *testing.T) {
	// Arrange
	handler := NewSystemMessageHandler()
	stopMsg := []byte(`189237`)

	// Act
	stopErr := handler.ProcessMessage(stopMsg)

	// Assert
	if stopErr == nil {
		t.Errorf("Returned nil from ProcessMessage, should have been error")
	}
}
