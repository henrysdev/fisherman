package common

// CommandRecord is the type that represents a local command history record
type CommandRecord struct {
	Command   string
	Timestamp int64
}

// CommandHistoryUpdateBody represents the body of the POST request send for history updates
type CommandHistoryUpdateBody struct {
	Commands []*CommandRecord
	// TODO metadata
}
