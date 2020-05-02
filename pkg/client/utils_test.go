package client

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"
)

const (
	filename  = "testfile"
	filename1 = filename + "_1"
)

func genArbitraryFile(name string, size int) {
	// Ex: dd if=/dev/zero of=output.dat bs=24M count=1
	nameClause := fmt.Sprintf("of=%s", name)
	sizeClause := fmt.Sprintf("bs=%v", size)
	cmd := exec.Command("dd", "if=/dev/zero", nameClause, sizeClause, "count=1")
	_, err := cmd.Output()
	if err != nil {
		panic(err)
	}
}

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

func TestOpenFileAtPos_WhenValidFileAndSeek_NoError(t *testing.T) {
	// Arrange
	genArbitraryFile(filename, 100)
	defer os.Remove(filename)

	// Act
	file, err := OpenFileAtPos(filename, 60)

	// Assert
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
	// Act
	_, err := OpenFileAtPos(filename, 60)

	// Assert
	if err == nil {
		t.Error("Failed to error on opening invalid file")
	}
	if !strings.Contains(err.Error(), "Invalid file") {
		t.Error("Failed to error for correct reason")
	}
}

func TestOpenFileAtPos_WhenOverflowSeek_Error(t *testing.T) {
	// Arrange
	genArbitraryFile(filename, 100)
	defer os.Remove(filename)

	// Act
	_, err := OpenFileAtPos(filename, 300)

	// Assert
	if err == nil {
		t.Error("Failed to error on seeking to invalid position")
	}
	if !strings.Contains(err.Error(), "Invalid seek position") {
		t.Error("Failed to error for correct reason")
	}
}

func TestOpenFileAtPos_WhenInvalidSeek_Error(t *testing.T) {
	// Arrange
	genArbitraryFile(filename, 100)
	defer os.Remove(filename)

	// Act
	_, err := OpenFileAtPos(filename, -1)

	// Assert
	if err == nil {
		t.Error("Failed to error on seeking to invalid position")
	}
	if !strings.Contains(err.Error(), "Invalid seek position") {
		t.Error("Failed to error for correct reason")
	}
}

func TestReadRestOfFile_WhenValid_NoError(t *testing.T) {
	// Arrange
	arbFile, _ := os.Create(filename)
	defer os.Remove(filename)
	fileContents := []byte("ABCDEF")
	arbFile.Write(fileContents)
	arbFile.Close()
	testFile, _ := os.Open(filename)
	seekPos := int64(2)
	testFile.Seek(seekPos, 0)

	// Act
	rest, err := ReadRestOfFile(testFile, seekPos)

	// Assert
	if err != nil {
		t.Errorf("Failed to read rest of file without error: %v", err)
	}
	for i, b := range rest {
		if fileContents[int(seekPos)+i] != b {
			t.Errorf("Rest data mismatch %v vs %v", fileContents[int(seekPos)+i], b)
		}
	}
}

func TestReadRestOfFile_WhenInvalidFile_Error(t *testing.T) {
	// Act
	_, err := ReadRestOfFile(nil, 100)

	// Assert
	if err == nil {
		t.Error("Failed to error on invalid file")
	}
}

func TestReadRestOfFile_WhenInvalidSeek_Error(t *testing.T) {
	// Act
	_, err := ReadRestOfFile(nil, -100)

	// Assert
	if err == nil {
		t.Error("Failed to error on invalid seek position")
	}
}

func TestFilesDiffer_WhenNotDifferent_False(t *testing.T) {
	// Arrange
	genArbitraryFile(filename, 100)
	cmd := exec.Command("cp", filename, filename1)
	cmd.Output()
	defer os.Remove(filename)
	defer os.Remove(filename1)

	// Act
	res, err := FilesDiffer(filename, filename1)

	// Assert
	if err != nil {
		t.Errorf("Failed by throwing error. No error should be thrown. Error: %v", err)
	}
	if res {
		t.Error("Failed. Should be no diff")
	}
}

func TestFilesDiffer_WhenDifferent_True(t *testing.T) {
	// Arrange
	file, _ := os.Create(filename)
	file1, _ := os.Create(filename1)
	defer os.Remove(filename)
	defer os.Remove(filename1)
	file.Write([]byte("abd"))
	file1.Write([]byte("ipoj"))
	file.Close()
	file1.Close()

	// Act
	res, err := FilesDiffer(filename, filename1)

	// Assert
	if err != nil {
		t.Errorf("Failed by throwing error %v", err)
	}
	if !res {
		t.Error("Failed by returning no diff")
	}
}
