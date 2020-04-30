package client

// BufferAPI provides an API for buffering command records before
// they are sent to their destination.
type BufferAPI interface {
	PushCommand(cmd string)
	IsEmpty() bool
	Take(n int) []*CommandRecord
}

// Buffer represents the state of the buffer
type Buffer struct {
	commands []*CommandRecord
}

// NewBuffer creates a new buffer instance
func NewBuffer() *Buffer {
	return &Buffer{}
}

// PushCommand appends a command to the current buffer
func (b *Buffer) PushCommand(cmd *CommandRecord) {
	b.commands = append(b.commands, cmd)
}

// Take returns the n oldest commands available
func (b *Buffer) Take(n int) []*CommandRecord {
	if n > len(b.commands) {
		n = len(b.commands)
	}
	if n <= 0 {
		return nil
	}
	cmds := b.commands[:n]
	b.commands = b.commands[n:]
	return cmds
}

// IsEmpty returns whether or not the commands field is empty
func (b *Buffer) IsEmpty() bool {
	return len(b.commands) == 0
}
