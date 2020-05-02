package client

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

// DispatchAPI provides an API for interacting with the client request dispatcher
type DispatchAPI interface {
	SendCmdHistoryUpdate(commands []*ExecutionRecord)
}

// Dispatcher represents the state of the client request dispatcher
type Dispatcher struct {
	client *http.Client
}

// NewDispatcher returns a new Dispatcher instance
func NewDispatcher() *Dispatcher {
	return &Dispatcher{
		client: &http.Client{},
	}
}

// SendCmdHistoryUpdate sends a message to the server with any new command records
func (c *Dispatcher) SendCmdHistoryUpdate(commands []*ExecutionRecord) error {

	PrettyPrintCommands(commands)

	// Form request
	reqBody, err := json.Marshal(CommandHistoryUpdateBody{
		Commands: commands,
	})
	if err != nil {
		return err
	}

	// Send request
	resp, err := http.Post(
		"127.0.0.1:8888/aaaa",
		"application/json",
		bytes.NewBuffer(reqBody))
	if err != nil {
		return err
	}

	// Handle response
	respBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	fmt.Println(string(respBody))
	return nil
}
