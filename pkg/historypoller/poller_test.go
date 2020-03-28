package historypoller

import (
	"os"
	"testing"
)

const (
	historyfile = "test_history_file"
	content     = `- cmd: docker list
	when: 1585083423
  - cmd: man dd
	when: 1585087362
  - cmd: cd utils
	when: 1585089273
	paths:
	  - utils
  - cmd: cd pkg/utils/
	when: 1585089279
	paths:
	  - pkg/utils/
  - cmd: less ~/.local/share/fish/fish_history
	when: 1585092659
  - cmd: man history -t
	when: 1585095367
  - cmd: clear
	when: 1585095382
  - cmd: fish history
	when: 1585095420
  - cmd: history -t
	when: 1585095520
  - cmd: vim ~/.local/share/fish/fish_history
	when: 1585095572
  - cmd: asd
	when: 1585095590
  - cmd: ;lkad
	when: 1585095606
  - cmd: agsfdgasdasd
	when: 1585095610
  - cmd: man history
	when: 1585095680
  - cmd: history
	when: 1585095694
  - cmd: cd ../poller
	when: 1585098958
	paths:
	  - ../poller
  - cmd: go tst
	when: 1585098959
  - cmd: less Users/abc.def/.local/share/fish/fish_history
	when: 1585099179
  - cmd: go test
	when: 1585099191  
	`
)

func TestNewPoller_WhenValidFile_NoError(t *testing.T) {
	dummyHistoryFile, _ := os.Create(historyfile)
	dummyHistoryFile.Write([]byte(content))
	poller := NewPoller(historyfile, 0)
	if poller.historyFile.Name() != historyfile {
		t.Error("History file name does not match file created")
	}
	fileInfo, _ := poller.historyFile.Stat()
	if fileInfo.Size() != int64(len(content)) {
		t.Error("History file size does not match file created")
	}
	os.Remove(historyfile)
}

func TestNewPoller_WhenInvalidFile_PanicError(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("Panic error was not thrown")
		}
	}()
	NewPoller(historyfile, 0)
}

func TestPoll(t *testing.T) {
	dummyHistoryFile, _ := os.Create(historyfile)
	dummyHistoryFile.Write([]byte(content))
	poller := NewPoller(historyfile, 0)
	poller.Poll()
	os.Remove(historyfile)
}
