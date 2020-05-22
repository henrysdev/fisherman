package httpclient

import (
	"bytes"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/henrysdev/fisherman/fishermand/pkg/common"
	"github.com/henrysdev/fisherman/fishermand/pkg/utils"
)

// DispatchAPI provides an API for interacting with the client request dispatcher
type DispatchAPI interface {
	SendCmdHistoryUpdate(commands []*common.ExecutionRecord) error
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
func (c *Dispatcher) SendCmdHistoryUpdate(commands []*common.ExecutionRecord) error {

	utils.PrettyPrint(commands)

	// Form request
	reqBody, err := json.Marshal(common.CommandHistoryUpdateBody{
		Commands: commands,
	})
	if err != nil {
		return err
	}

	// Send request
	resp, err := http.Post(
		"http://localhost:4000/shellmsg", "application/json", bytes.NewBuffer(reqBody))
	if err != nil {
		return err
	}

	// Handle response
	respBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	log.Println(string(respBody))
	return nil
}
