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
	client   *http.Client
	currUser *common.User
	hostURL  string
}

// NewDispatcher returns a new Dispatcher instance
func NewDispatcher(hostURL string) *Dispatcher {
	return &Dispatcher{
		client:  &http.Client{},
		hostURL: hostURL,
	}
}

// SendCmdHistoryUpdate sends a message to the server with any new command records
func (c *Dispatcher) SendCmdHistoryUpdate(commands []*common.ExecutionRecord) error {
	if c.currUser == nil {
		log.Fatalf("Shell dispatch called before registering user with server")
		return nil
	}
	utils.PrettyPrint(commands)

	// Form request
	reqBody, err := json.Marshal(common.CommandHistoryUpdateBody{
		Commands: commands,
		UserID:   c.currUser.UserID,
	})
	if err != nil {
		return err
	}

	// Send request
	resp, err := c.client.Post(
		c.hostURL+"/api/shellmsg", "application/json", bytes.NewBuffer(reqBody))
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

// RegisterUser calls to creates a new user and receives the userId in the response
func (c *Dispatcher) RegisterUser(user *common.User) error {
	utils.PrettyPrint(user)

	// Form request
	reqBody, err := json.Marshal(user)
	if err != nil {
		return err
	}

	// Send request
	resp, err := c.client.Post(
		c.hostURL+"/api/user", "application/json", bytes.NewBuffer(reqBody))
	if err != nil {
		return err
	}

	// Handle response
	respBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	log.Println(string(respBody))

	var createdUser common.User
	if err := json.Unmarshal(respBody, &createdUser); err != nil {
		return err
	}
	c.currUser = &createdUser

	return nil
}
