package application

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/pkg/errors"

	"github.com/henrysdev/fisherman/fishermand/pkg/utils"
)

// Run reads the config, starts the fisherman daemon process, and starts trap for system signals
func Run(cfgFilepath string) {
	cfg, err := ParseConfig(cfgFilepath)
	if err != nil {
		panic(err)
	}
	go func() {
		fisherman := NewFisherman(cfg)
		fisherman.Start()
	}()
	trap(cfg)
}

// Trap watches for signals in order to exit gracefully with cleanup
func trap(cfg *Config) {
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

	sig := <-killSignal
	log.Println("Exiting with signal: ", sig)

	cleanup(cfg)
	os.Exit(1)
}

// Cleanup destroys temp files that are created
func cleanup(cfg *Config) {
	// Destroy fifo pipe (very important to prevent deadlock with shell!)
	if err := utils.RemoveFile(cfg.FifoPipe); err != nil {
		log.Fatal(errors.Wrap(err, "Failed to remove fifo pipe "))
	}
	// Destroy any/all files in temp directory
	if err := utils.CleanDirectory(cfg.TempDirectory); err != nil {
		log.Fatal(errors.Wrap(err, "Failed to remove some temp files"))
	}
}
