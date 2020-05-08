package application

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/pkg/errors"

	httpclient "github.com/henrysdev/fisherman/fishermand/pkg/http_client"
	shellpipe "github.com/henrysdev/fisherman/fishermand/pkg/message_pipes/shell_pipe"
	systempipe "github.com/henrysdev/fisherman/fishermand/pkg/message_pipes/system_pipe"
	"github.com/henrysdev/fisherman/fishermand/pkg/utils"
)

// Run reads the config, starts the fisherman daemon process, and starts trap for system signals
func Run(cfgFilepath string) {
	// Read in config
	cfg, err := ParseConfig(cfgFilepath)
	utils.PrettyPrint(cfg)
	if err != nil {
		panic(err)
	}

	// Start fifo pipe processes
	go initPipes(cfg)

	// Block for os level exit signals
	trap(cfg)
}

func initPipes(cfg *Config) error {
	// Initialize system pipe
	systemPipe := systempipe.NewSystemListener(
		cfg.SystemPipe,
		systempipe.NewSystemMessageHandler(),
	)
	if err := systemPipe.Setup(); err != nil {
		return errors.Wrap(err, "failed to setup system pipe")
	}

	// Initialize shell pipe
	buffer := shellpipe.NewBuffer()
	shellPipe := shellpipe.NewShellListener(
		cfg.ShellPipe,
		buffer,
		httpclient.NewDispatcher(),
		cfg.UpdateFrequency,
		cfg.MaxCmdsPerUpdate,
		shellpipe.NewShellMessageHandler(buffer),
	)
	if err := shellPipe.Setup(); err != nil {
		return errors.Wrap(err, "failed to setup shell pipe")
	}

	return supervisePipes(systemPipe, shellPipe, cfg)
}

func supervisePipes(
	systemPipe *systempipe.SystemListener,
	shellPipe *shellpipe.ShellListener,
	cfg *Config,
) error {
	// Start polling the read end of the system pipe
	go func() {
		defer panicHandler(cfg)
		// Log bubbled up errors
		for {
			if err := systemPipe.Listen(); err != nil {
				log.Fatal(errors.Wrap(err, "system pipe listen failed"))
			}
		}
	}()

	// Start polling the read end of the shell pipe
	go func() {
		defer panicHandler(cfg)
		// Log bubbled up errors
		for {
			if err := shellPipe.Listen(); err != nil {
				log.Println(errors.Wrap(err, "shell pipe listen failed"))
			}
		}
	}()

	return nil
}

func panicHandler(cfg *Config) {
	if r := recover(); r != nil {
		gracefulExit(cfg, r)
	}
}

func gracefulExit(cfg *Config, reason interface{}) {
	log.Println("shutting down...")
	cleanup(cfg)
	if reason != nil {
		log.Fatal(fmt.Sprintf("crashed due to %v", reason))
	}
	os.Exit(1)
}

// Trap watches for signals in order to exit gracefully with cleanup
func trap(cfg *Config) {
	killSignal := make(chan os.Signal, 1)
	signal.Notify(killSignal,
		syscall.SIGABRT,
		syscall.SIGBUS,
		syscall.SIGCONT,
		syscall.SIGFPE,
		syscall.SIGHUP,
		syscall.SIGILL,
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
	err := fmt.Errorf("encountered system signal: %v", sig)
	log.Println(err)
	gracefulExit(cfg, err)
}

// Cleanup destroys temp files that are created
func cleanup(cfg *Config) {
	log.Println("deleting system pipe...")
	if err := utils.RemoveFile(cfg.SystemPipe); err != nil {
		log.Fatal(errors.Wrap(err, "failed to remove system pipe "))
	}
	// Destroy shell and system pipe (very important to prevent deadlock with shell!)
	log.Println("deleting shell pipe...")
	if err := utils.RemoveFile(cfg.ShellPipe); err != nil {
		log.Fatal(errors.Wrap(err, "failed to remove shell pipe "))
	}
	// Destroy any/all files in temp directory
	if err := utils.CleanDirectory(cfg.TempDirectory); err != nil {
		log.Fatal(errors.Wrap(err, "failed to remove some temp files"))
	}
}
