package historypoller

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/henrysdev/fisherman/pkg/utils"
)

// https://github.com/fish-shell/fish-shell/issues/862
// SAVE
// currUser, err := user.Current()
// if err != nil {
// 	return nil, err
// }
// filePath := path.Join([]string{
// 	"/Users",
// 	currUser.Username,
// 	historyFilepath}...)
// const (
// 	legacyFishHistoryFilepath  = ".config/fish/fish_history"
// 	currentFishHistoryFilepath = ".local/share/fish/fish_history"
// )

// API for polling fish history file for changes
type API interface {
	Init() error
	Poll() ([]*CommandRecord, error)
}

// Poller keeps track of polling state between polls
type Poller struct {
	historyFile *os.File
	seekPos     int64
}

//TODO move to own package[?]
type CommandRecord struct {
	cmd  string
	when *time.Time
}

// NewPoller prepares the poller to start polling by finding the fish history file and populating
// the Poller with the pertinent values.
func NewPoller(historyFilepath string, seekPos int64) *Poller {
	historyFile, err := openHistoryFile(historyFilepath, seekPos)
	if err != nil {
		panic(err)
	}
	return &Poller{
		historyFile: historyFile,
		seekPos:     seekPos,
	}
}

// Poll scans for file changes in the fish history log, formatting and returning any
// new found logs
func (p *Poller) Poll() ([]*CommandRecord, error) {
	// 1. Read from seek pos to end of file
	rest, err := utils.ReadRestOfFile(p.historyFile, p.seekPos)
	if err != nil {
		return nil, err
	}

	if len(rest) == 0 {
		fmt.Println("No new records found")
		return nil, nil
	}

	// 2. Cast []byte to string
	strContents := string(rest)

	// 3. Split by entry
	rawEntries := strings.Split(strContents, "- cmd:")
	for i := range rawEntries {
		rawEntries[i] = strings.Trim(rawEntries[i], " ")
	}

	// TODO figure out way to utilize Fish's wacky history log.
	// Ideas: Only send positive diffs ?

	// 4. Parse out timestamps
	// 5. Return found entries
	// 6. Update seek position
	return nil, nil
}

func openHistoryFile(historyFilepath string, seekPos int64) (*os.File, error) {
	if !utils.FileExists(historyFilepath) {
		return nil, fmt.Errorf("No fish history file found. Checked: %v", historyFilepath)
	}

	historyFile, err := utils.OpenFileAtPos(historyFilepath, seekPos)
	if err != nil {
		return nil, err
	}

	return historyFile, nil
}
