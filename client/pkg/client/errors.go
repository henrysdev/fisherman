package client

import (
	"fmt"
)

// ShellMessageFormatError returns an error for a malformed message received
func ShellMessageFormatError(errStr string) error {
	return fmt.Errorf("Malformed message encountered, %s", errStr)
}
