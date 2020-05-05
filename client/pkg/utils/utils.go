package utils

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/henrysdev/fisherman/client/pkg/common"
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

// PrettyPrintCommands prints out lists of commands formatted for convenient debugging
func PrettyPrintCommands(commands []*common.ExecutionRecord) {
	if len(commands) == 0 {
		return
	}
	listStr := ""
	n := len(commands)
	for i := 0; i < len(commands)-1; i++ {
		command := commands[i]
		listStr += fmt.Sprintf("{ cmd:%v, err:%v, ts:%v }\n", command.Command.Line, command.Stderr.Line, command.Command.Timestamp)
	}
	listStr += fmt.Sprintf("{ cmd:%v, err:%v, ts:%v }", commands[n-1].Command.Line, commands[n-1].Stderr.Line, commands[n-1].Command.Timestamp)
	wholeStr := fmt.Sprintf("[%v]\n", listStr)
	fmt.Println(wholeStr)
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
