package client

import (
	"testing"
)

// TODO generate proper mock for flag interface and
// write more test cases
func TestParseFlags_WhenNoArguments_APIKeyError(t *testing.T) {
	config, err := ParseFlags()
	if err == nil {
		t.Error("No error thrown by lack of api key")
	}
	if config != nil {
		t.Error("Config not equal to nil as expected")
	}
}
