package message_apid

import "github.com/henrysdev/fisherman/client/pkg/common"

// BufferAPI provides an API for buffering command records before they are sent to their
// destination. It acts as a queue for execution records to send to the server.
type BufferAPI interface {
	PushExecutionRecord(cmd string)
	IsEmpty() bool
	Take(n int) []*common.ExecutionRecord
}

// Buffer represents the state of the buffer
type Buffer struct {
	elements []*common.ExecutionRecord
}

// NewBuffer creates a new buffer instance
func NewBuffer() *Buffer {
	return &Buffer{}
}

// PushExecutionRecord appends a command to the current buffer
func (b *Buffer) PushExecutionRecord(cmd *common.ExecutionRecord) {
	b.elements = append(b.elements, cmd)
}

// TakeN returns the n oldest elements available
func (b *Buffer) TakeN(n int) []*common.ExecutionRecord {
	if n > len(b.elements) {
		n = len(b.elements)
	}
	if n <= 0 {
		return nil
	}
	cmds := b.elements[:n]
	b.elements = b.elements[n:]
	return cmds
}

// IsEmpty returns whether or not the elements field is empty
func (b *Buffer) IsEmpty() bool {
	return len(b.elements) == 0
}
