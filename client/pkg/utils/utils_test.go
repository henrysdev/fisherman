package utils

import (
	"os"
	"testing"
)

const (
	filename = "testfile"
)

func TestFileExists_WhenDoesExist_True(t *testing.T) {
	// Arrange
	os.Create(filename)
	defer os.Remove(filename)

	// Act
	fileExists := FileExists(filename)

	// Assert
	if !fileExists {
		t.Errorf("File `%v` should exist", filename)
	}
}

func TestFileExists_WhenDoesNotExist_False(t *testing.T) {
	// Arrange
	os.Create(filename)
	os.Remove(filename)

	// Act
	fileExists := FileExists(filename)

	// Assert
	if fileExists {
		t.Errorf("File `%v` shoud not exist", filename)
	}
}
