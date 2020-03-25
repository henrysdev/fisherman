package utils

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"
)

const (
	filename = "testfile"
)

func genArbitraryFile(name string, size int) {
	// Ex: dd if=/dev/zero of=output.dat bs=24M count=1
	cmd := exec.Command(
		"dd",
		[]string{"if=/dev/zero",
			fmt.Sprintf("of=%s", name),
			fmt.Sprintf("bs=%v", size),
			"count=1"}...)
	_, err := cmd.Output()
	if err != nil {
		panic(err)
	}
}

func TestFileExists_WhenDoesExist_True(t *testing.T) {
	os.Create(filename)
	if !FileExists(filename) {
		t.Errorf("File `%v` should exist", filename)
	}
	os.Remove(filename)
}

func TestFileExists_WhenDoesNotExist_False(t *testing.T) {
	os.Create(filename)
	os.Remove(filename)
	if FileExists(filename) {
		t.Errorf("File `%v` shoud not exist", filename)
	}
}

func TestOpenFileAtPos_WhenValidFileAndSeek_NoError(t *testing.T) {
	genArbitraryFile(filename, 100)
	defer os.Remove(filename)

	file, err := OpenFileAtPos(filename, 60)
	if err != nil {
		t.Error("Failed to open file at position")
	}
	buf := make([]byte, 300)
	rest, err := file.Read(buf)
	if rest != 40 {
		t.Error("Cursor not seeking to correct position")
	}
}

func TestOpenFileAtPos_WhenInvalidFile_Error(t *testing.T) {
	_, err := OpenFileAtPos(filename, 60)
	if err == nil {
		t.Error("Failed to error on opening invalid file")
	}
	if !strings.Contains(err.Error(), "Invalid file") {
		t.Error("Failed to error for correct reason")
	}
}

func TestOpenFileAtPos_WhenOverflowSeek_Error(t *testing.T) {
	genArbitraryFile(filename, 100)
	defer os.Remove(filename)

	_, err := OpenFileAtPos(filename, 300)
	if err == nil {
		t.Error("Failed to error on seeking to invalid position")
	}
	if !strings.Contains(err.Error(), "Invalid seek position") {
		t.Error("Failed to error for correct reason")
	}
}

func TestOpenFileAtPos_WhenInvalidSeek_Error(t *testing.T) {
	genArbitraryFile(filename, 100)
	defer os.Remove(filename)

	_, err := OpenFileAtPos(filename, -1)
	if err == nil {
		t.Error("Failed to error on seeking to invalid position")
	}
	if !strings.Contains(err.Error(), "Invalid seek position") {
		t.Error("Failed to error for correct reason")
	}
}

func TestReadRestOfFile_WhenValid_NoError(t *testing.T) {
	// Write some file contents
	arbFile, _ := os.Create(filename)
	fileContents := []byte("ABCDEF")
	arbFile.Write(fileContents)
	arbFile.Close()

	// Seek to an arbitrary position and assert that rest read is correct
	testFile, _ := os.Open(filename)
	seekPos := int64(2)
	testFile.Seek(seekPos, 0)
	rest, err := ReadRestOfFile(testFile, seekPos)
	if err != nil {
		t.Errorf("Failed to read rest of file without error: %v", err)
	}
	for i, b := range rest {
		if fileContents[int(seekPos)+i] != b {
			t.Errorf("Rest data mismatch %v vs %v", fileContents[int(seekPos)+i], b)
		}
	}
	os.Remove(filename)
}

func TestReadRestOfFile_WhenInvalidFile_Error(t *testing.T) {
	_, err := ReadRestOfFile(nil, 100)
	if err == nil {
		t.Error("Failed to error on invalid file")
	}
}

func TestReadRestOfFile_WhenInvalidSeek_Error(t *testing.T) {
	_, err := ReadRestOfFile(nil, -100)
	if err == nil {
		t.Error("Failed to error on invalid seek position")
	}
}
