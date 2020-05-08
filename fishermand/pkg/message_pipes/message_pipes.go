package messagepipes

// ListenerAPI provides a generic interface for pipe listener processes
type ListenerAPI interface {
	Setup() error
	Listen() error
}

// HandlerAPI provides a generic interface for message handlers
type HandlerAPI interface {
	ProcessMessage(msgBytes []byte) error
}
