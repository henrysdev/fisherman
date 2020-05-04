package client

// Enum for message type
type messagetype int

const (
	COMMAND messagetype = iota
	STDERR
)

// ShellMessage represents a message passed to the consumer from a shell process
type ShellMessage struct {
	PID             string
	MessageType     messagetype
	MessageContents string
	Timestamp       int64
}

// Command represents a command run from the shell
type Command struct {
	Line      string
	Timestamp int64
}

// Stderr represents a stderr output
type Stderr struct {
	Line      string
	Timestamp int64
}

// ExecutionRecord is the type that represents a local command history record
type ExecutionRecord struct {
	Command *Command
	Stderr  *Stderr
}

// CommandHistoryUpdateBody represents the body of the POST request send for history updates
type CommandHistoryUpdateBody struct {
	Commands []*ExecutionRecord
	// TODO metadata
}
