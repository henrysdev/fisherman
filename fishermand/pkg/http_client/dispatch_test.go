package httpclient

import (
	"errors"
	"io/ioutil"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/henrysdev/fisherman/fishermand/pkg/common"
)

type roundTripFunc func(r *http.Request) (*http.Response, error)

func (s roundTripFunc) RoundTrip(r *http.Request) (*http.Response, error) {
	return s(r)
}

var (
	DefaultUser = &common.User{
		Email:         "foobarfoo@gmail.com",
		FirstName:     "henry",
		LastName:      "warren",
		MachineSerial: "xycj2oijdas",
		Username:      "foo.bar",
	}
)

func TestSendCmdHistoryUpdate(t *testing.T) {
	// Arrange
	var stubClient http.Client
	stubClient.Transport = roundTripFunc(func(r *http.Request) (*http.Response, error) {
		if r.URL.Path != "/api/shellmsg" {
			t.Errorf("Expected url path to be /shellmsg, got: %v", r.URL.Path)
		}
		return &http.Response{
			StatusCode: http.StatusOK,
			Body:       ioutil.NopCloser(strings.NewReader(`{}`)),
		}, nil
	})
	dispatcher := NewDispatcher("")
	dispatcher.currUser = &common.User{
		UserID: "abc-123-def-456",
	}
	dispatcher.client = &stubClient
	payload := []*common.ExecutionRecord{
		{
			PID: "123",
			Command: &common.Command{
				Line:      "ls -lzzgha",
				Timestamp: time.Now().UnixNano() / 1000000,
			},
			Stderr: &common.Stderr{
				Line:      "exit status 1 unknown option for ls `z`",
				Timestamp: time.Now().UnixNano() / 1000000,
			},
		},
	}

	// Act
	err := dispatcher.SendCmdHistoryUpdate(payload)

	// Assert
	if err != nil {
		t.Errorf("Error should be nil but got: %v", err)
	}
}

func TestRegisterUser(t *testing.T) {
	// Arrange
	var stubClient http.Client
	stubClient.Transport = roundTripFunc(func(r *http.Request) (*http.Response, error) {
		if r.URL.Path != "/api/user" {
			t.Errorf("Expected url path to be /user, got: %v", r.URL.Path)
		}
		return &http.Response{
			StatusCode: http.StatusOK,
			Body:       ioutil.NopCloser(strings.NewReader(`{"user_id":"12312-daw3-32ioads"}`)),
		}, nil
	})
	dispatcher := NewDispatcher("")
	dispatcher.currUser = &common.User{
		UserID: "abc-123-def-456",
	}
	dispatcher.client = &stubClient

	// Act
	err := dispatcher.RegisterUser(DefaultUser)

	// Assert
	if err != nil {
		t.Errorf("Error should be nil but got: %v", err)
	}
}

func TestRegisterUser_WhenBadResponse_Error(t *testing.T) {
	// Arrange
	var stubClient http.Client
	stubClient.Transport = roundTripFunc(func(r *http.Request) (*http.Response, error) {
		if r.URL.Path != "/api/user" {
			t.Errorf("Expected url path to be /user, got: %v", r.URL.Path)
		}
		return nil, errors.New("server error")
	})
	dispatcher := NewDispatcher("")
	dispatcher.currUser = &common.User{
		UserID: "abc-123-def-456",
	}
	dispatcher.client = &stubClient

	// Act
	err := dispatcher.RegisterUser(DefaultUser)

	// Assert
	if err == nil {
		t.Error("Error should not be nil")
	}
}

func TestRegisterUser_WhenUnmarshalError_Error(t *testing.T) {
	// Arrange
	var stubClient http.Client
	stubClient.Transport = roundTripFunc(func(r *http.Request) (*http.Response, error) {
		if r.URL.Path != "/api/user" {
			t.Errorf("Expected url path to be /user, got: %v", r.URL.Path)
		}
		return &http.Response{
			StatusCode: http.StatusOK,
			Body: ioutil.NopCloser(strings.NewReader(`asdf{32	"usafw3er_id":"12312-daw3-32ioads"}`)),
		}, nil
	})
	dispatcher := NewDispatcher("")
	dispatcher.currUser = &common.User{
		UserID: "abc-123-def-456",
	}
	dispatcher.client = &stubClient

	// Act
	err := dispatcher.RegisterUser(DefaultUser)

	// Assert
	if err == nil {
		t.Error("Error should not be nil")
	}
}
