package application

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/henrysdev/fisherman/fishermand/pkg/http_client"
)

var (
	errSetup     = fmt.Errorf("Setup error")
	errArbitrary = fmt.Errorf("Arbitrary error")
)

// MockConsumer
type MockConsumerAPI interface {
	Setup() error
	Listen(errorChan chan error)
}
type MockConsumer struct {
	spoofMode string
	delay     int
}

func (m *MockConsumer) Setup() error {
	switch m.spoofMode {
	case "setup_error":
		return errSetup
	default:
		return nil
	}
}

func (m *MockConsumer) Listen(errorChan chan error) {
	switch m.spoofMode {
	case "error":
		errorChan <- errArbitrary
	case "delay":
		go func() {
			time.AfterFunc(
				time.Second*time.Duration(m.delay),
				func() { errorChan <- errArbitrary })
		}()
	default:
		errorChan <- errArbitrary
	}
}

func TestStartFisherman(t *testing.T) {
	// Arrange
	delay := 1
	cfg := &Config{
		TempDirectory:    ".",
		FifoPipe:         ".",
		UpdateFrequency:  int64(0),
		MaxCmdsPerUpdate: 1,
	}
	dispatcher := http_client.NewDispatcher()
	consumer := &MockConsumer{
		spoofMode: "delay",
		delay:     delay,
	}
	fisherman := &Fisherman{
		Config:     cfg,
		Consumer:   consumer,
		Dispatcher: dispatcher,
	}
	beforeTime := time.Now()

	// Act
	fisherman.Start()

	// Assert
	if int(time.Since(beforeTime).Seconds()) < delay {
		t.Errorf("Should have been delayed %d seconds", delay)
	}
}

func TestStartFisherman_WhenConsumerSetupError_ShouldError(t *testing.T) {
	// Arrange
	cfg := &Config{
		TempDirectory:    ".",
		FifoPipe:         ".",
		UpdateFrequency:  int64(0),
		MaxCmdsPerUpdate: 1,
	}
	dispatcher := http_client.NewDispatcher()
	consumer := &MockConsumer{
		spoofMode: "setup_error",
	}
	fisherman := &Fisherman{
		Config:     cfg,
		Consumer:   consumer,
		Dispatcher: dispatcher,
	}

	// Act
	err := fisherman.Start()

	// Assert
	if !strings.Contains(err.Error(), errSetup.Error()) {
		t.Errorf("Err should contain expected error, got %v", err)
	}
}

func TestStartFisherman_WhenConsumerListenError_ShouldError(t *testing.T) {
	// Arrange
	cfg := &Config{
		TempDirectory:    ".",
		FifoPipe:         ".",
		UpdateFrequency:  int64(0),
		MaxCmdsPerUpdate: 1,
	}
	dispatcher := http_client.NewDispatcher()
	consumer := &MockConsumer{
		spoofMode: "error",
	}
	fisherman := &Fisherman{
		Config:     cfg,
		Consumer:   consumer,
		Dispatcher: dispatcher,
	}

	// Act
	err := fisherman.Start()

	// Assert
	if errArbitrary != err {
		t.Errorf("Err should be equal to expected error, got %v", errArbitrary)
	}
}
