package httpclient

import (
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

func TestSendCmdHistoryUpdate(t *testing.T) {
	// Arrange
	var stubClient http.Client
	stubClient.Transport = roundTripFunc(func(r *http.Request) (*http.Response, error) {
		if r.URL.Path != "/shellmsg" {
			t.Errorf("Expected url path to be /shellmsg, got: %v", r.URL.Path)
		}
		return &http.Response{
			StatusCode: http.StatusOK,
			Body:       ioutil.NopCloser(strings.NewReader(`{}`)),
		}, nil
	})
	userID := "abc-123-def-456"
	dispatcher := NewDispatcher(userID)
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
