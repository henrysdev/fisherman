package client

// ShellProcessAPI exposes an API for interacting with shell process state
type ShellProcessAPI interface {
	PushCommand(command *Command)
	PushStderror(stderr *Stderr) *ExecutionRecord
}

// ShellProcess represents the state of a shell the program receives messages from
type ShellProcess struct {
	PID     string
	Command *Command
	Stderr  *Stderr
}

// NewShellProcess returns a new ShellProcess instance
func NewShellProcess(pid string, command *Command) *ShellProcess {
	return &ShellProcess{
		PID:     pid,
		Command: command,
	}
}

// PushCommand stores the command
func (s *ShellProcess) PushCommand(command *Command) {
	s.Command = command
}

// PushStderr stores the command and return an execution record
func (s *ShellProcess) PushStderr(stderr *Stderr) *ExecutionRecord {
	if s.Command == nil {
		return nil
	}
	record := &ExecutionRecord{
		Command: s.Command,
		Stderr:  stderr,
	}
	s.Command = nil
	s.Stderr = nil
	return record
}
