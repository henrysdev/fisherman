package common

// Messagetype enum for all supported IPC messages from shell processes
type Messagetype int

const (
	// COMMAND message from shell
	COMMAND Messagetype = iota
	// STDERR message from shell
	STDERR
	// EXIT message from shell
	EXIT
)

// ShellMessage represents a message passed to the listener from a shell process
type ShellMessage struct {
	PID             string
	MessageType     Messagetype
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

// ExitSignal represent an exit signal from the shell
type ExitSignal struct {
	Info      string
	Timestamp int64
}

// ExecutionRecord is the type that represents a local command history record
type ExecutionRecord struct {
	PID        string
	Command    *Command
	Stderr     *Stderr
	ExitSignal *ExitSignal
}

// CommandHistoryUpdateBody represents the body of the POST request send for history updates
type CommandHistoryUpdateBody struct {
	Commands []*ExecutionRecord
	// TODO metadata
}
