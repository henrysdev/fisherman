package systempipe

import (
	"os/exec"

	"github.com/pkg/errors"

	messagepipes "github.com/henrysdev/fisherman/fishermand/pkg/message_pipes"
)

// SystemListener represents the state of a command consumer
type SystemListener struct {
	fifoPipe string
	handler  messagepipes.HandlerAPI
}

// NewSystemListener returns a new SystemListener instance
func NewSystemListener(
	fifoPipe string,
	handler messagepipes.HandlerAPI,
) *SystemListener {
	return &SystemListener{
		fifoPipe: fifoPipe,
		handler:  handler,
	}
}

// Setup is a method that sets up the consumer to be ready. Should be called immediately
// after instantiation
func (c *SystemListener) Setup() error {
	exec.Command("rm", c.fifoPipe).Output()
	_, err := exec.Command("mkfifo", c.fifoPipe).Output()
	if err != nil {
		return err
	}
	return nil
}

// Listen continuously polls for new IPC messages sent over a fifo pipe written to from local
// shell processes and the CLI. Send updates to server when appropriate.
func (c *SystemListener) Listen() error {
	for {
		resp, err := exec.Command("cat", c.fifoPipe).Output()
		if err != nil {
			return errors.Wrap(err, "system listener failed to read pipe")
		}

		err = c.handler.ProcessMessage(resp)
		if err != nil {
			return errors.Wrap(err, "system listener failed to process message")
		}
	}
}
