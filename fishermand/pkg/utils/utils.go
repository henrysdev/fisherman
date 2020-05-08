package utils

import (
	"encoding/json"
	"log"
	"os"
	"os/exec"
	"path/filepath"
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

// PrettyPrint prints out arbitrary interface as pretty JSON
func PrettyPrint(structure interface{}) {
	b, _ := json.MarshalIndent(structure, "", " ")
	log.Println(string(b))
}

// RemoveFile removes the file descriptor at the provided location
func RemoveFile(filename string) error {
	_, err := exec.Command("rm", filename).Output()
	return err
}

// CleanDirectory removes all files under a given directory
func CleanDirectory(directory string) error {
	files, err := filepath.Glob(filepath.Join(directory, "*"))
	if err != nil {
		return err
	}
	for _, file := range files {
		err = os.RemoveAll(file)
		if err != nil {
			return err
		}
	}
	return nil
}
