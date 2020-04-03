package utils

import (
	"fmt"
	"os"
	"os/exec"
)

// FileExists checks if a file exists and is not a directory before we
// try using it to prevent further errors.
func FileExists(filename string) bool {
	info, err := os.Stat(filename)
	if os.IsNotExist(err) {
		return false
	}
	return !info.IsDir()
}

// OpenFileAtPos attempts to open and return a file handle to a file
// at provided byte position, handling any encountered errors
func OpenFileAtPos(filename string, seekPos int64) (*os.File, error) {
	if seekPos < 0 {
		return nil, fmt.Errorf("OpenFileAtPos failed: Invalid seek position %v", seekPos)
	}
	if !FileExists(filename) {
		return nil, fmt.Errorf("OpenFileAtPos failed: Invalid file %v (does not exist)", filename)
	}
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	// Validate that seek position is within file scope
	if info, _ := os.Stat(filename); info != nil {
		if seekPos >= info.Size() {
			return nil, fmt.Errorf(
				"OpenFileAtPos failed: Invalid seek position %v for file %s of size %v",
				seekPos,
				filename,
				info.Size())
		}
	}

	if _, err = file.Seek(seekPos, 0); err != nil {
		return nil, err
	}
	return file, nil
}

// ReadRestOfFile attempts to read in the remainder of a file from the filehandle
// cursor's current position
func ReadRestOfFile(file *os.File, seekPos int64) ([]byte, error) {
	if seekPos < 0 {
		return nil, fmt.Errorf("OpenFileAtPos failed: Invalid seek position %v", seekPos)
	}
	info, err := file.Stat()
	if err != nil {
		return nil, err
	}
	if seekPos >= info.Size() {
		return nil, fmt.Errorf(
			"OpenFileAtPos failed: Invalid seek position %v for file %s of size %v",
			seekPos,
			file.Name(),
			info.Size())
	}
	remBytes := info.Size() - seekPos
	restBuffer := make([]byte, remBytes)
	_, err = file.Read(restBuffer)
	if err != nil {
		return nil, err
	}
	return restBuffer, nil
}

// FilesDiffer determines whether files at the given filepaths differ in content. This function
// simply wraps the "cmp" unix command.
func FilesDiffer(firstFilepath string, secondFilepath string) (bool, error) {
	cmd := exec.Command("cmp", firstFilepath, secondFilepath)
	_, err := cmd.Output()
	if err != nil && err.Error() == "exit status 1" {
		return true, nil
	}
	return false, err
}

// PositiveDiff returns only positive additions in a diff comparing the contents of files located
// at filepaths currFilepath and newFilepath. No positive diffs will return an empty string
func PositiveDiff(currFilepath string, newFilepath string) ([]byte, error) {
	// diff -u $lastfilepath $newfilepath | grep -E "^\+" > $diffpath
	cmd := exec.Command("diff", "-u", currFilepath, newFilepath, "|", "grep", `-E^\+`)
	output, err := cmd.Output()
	fmt.Println("output: ", output)
	if err != nil {
		return nil, err
	}
	return output, nil
}
