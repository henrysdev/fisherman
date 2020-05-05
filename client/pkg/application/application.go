package application

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/pkg/errors"

	"github.com/henrysdev/fisherman/client/pkg/utils"
)

// Run starts the fisherman daemon process and handles system signal events
func Run() {
	cfg, err := ParseConfig()
	if err != nil {
		panic(err)
	}

	killSignal := make(chan os.Signal, 1)
	signal.Notify(killSignal,
		syscall.SIGABRT,
		syscall.SIGBUS,
		syscall.SIGCONT,
		syscall.SIGEMT,
		syscall.SIGFPE,
		syscall.SIGHUP,
		syscall.SIGILL,
		syscall.SIGINFO,
		syscall.SIGINT,
		syscall.SIGIO,
		syscall.SIGIOT,
		syscall.SIGKILL,
		syscall.SIGPIPE,
		syscall.SIGPROF,
		syscall.SIGQUIT,
		syscall.SIGSEGV,
		syscall.SIGSTOP,
		syscall.SIGSYS,
		syscall.SIGTERM,
		syscall.SIGTRAP,
		syscall.SIGTSTP,
		syscall.SIGTTIN,
		syscall.SIGTTOU,
		syscall.SIGURG,
		syscall.SIGUSR1,
		syscall.SIGUSR2,
		syscall.SIGXFSZ)

	go func() {
		defer func() {
			if r := recover(); r != nil {
				err := r.(error)
				fmt.Println("Error: ", err)
				cleanup(cfg)
			}
		}()
		fisherman := NewFisherman(cfg)
		fisherman.Start()
	}()

	sig := <-killSignal
	fmt.Println("Exiting with signal: ", sig)

	cleanup(cfg)
	os.Exit(1)
}

func cleanup(cfg *Config) {
	// Destroy fifo pipe (very important to prevent deadlock with shell!)
	if err := utils.RemoveFile(cfg.FifoPipe); err != nil {
		fmt.Println(errors.Wrap(err, "Failed to remove fifo pipe! "))
	}

	// Destroy any/all files in temp directory
	if err := utils.CleanDirectory(cfg.TempDirectory); err != nil {
		fmt.Println(errors.Wrap(err, "Failed to remove some temp files"))
	}
}
