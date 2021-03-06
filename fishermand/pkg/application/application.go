package application

import (
	"context"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/pkg/errors"

	httpclient "github.com/henrysdev/fisherman/fishermand/pkg/http_client"
	messagepipes "github.com/henrysdev/fisherman/fishermand/pkg/message_pipes"
	shellpipe "github.com/henrysdev/fisherman/fishermand/pkg/message_pipes/shell_pipe"
	"github.com/henrysdev/fisherman/fishermand/pkg/utils"
)

// Init reads in the config file, initializes pipes, and starts running the client
func Init(cfgFilepath string) {
	// Read in config
	cfg, err := ParseConfig(cfgFilepath)
	utils.PrettyPrint(cfg)
	if err != nil {
		panic(err)
	}
	shellPipe, err := initPipe(cfg)
	if err != nil {
		panic(err)
	}

	run(cfg, shellPipe)
}

// run reads the config, starts the fisherman daemon process, and starts trap for system signals
func run(cfg *Config, shellPipe *shellpipe.ShellListener) {
	ctx, cancel := context.WithCancel(context.Background())
	// Start polling the read end of the shell pipe
	supervisePipe(ctx, cancel, cfg, shellPipe, cfg.ShellPipe)

	// Block for OS level exit signals
	trap(cfg, cancel)
}

// initPipe instantiates the unix fifo pipe as well as their listeners
func initPipe(cfg *Config) (*shellpipe.ShellListener, error) {
	// Register with server
	httpDispatch := httpclient.NewDispatcher(cfg.HostURL)
	if err := httpDispatch.RegisterUser(cfg.User); err != nil {
		return nil, errors.Wrap(err, "failed to register user with server")
	}

	// Initialize shell pipe
	buffer := shellpipe.NewBuffer()
	shellPipe := shellpipe.NewShellListener(
		cfg.ShellPipe,
		buffer,
		httpDispatch,
		cfg.UpdateFrequency,
		cfg.MaxCmdsPerUpdate,
		shellpipe.NewShellMessageHandler(buffer),
	)
	if err := shellPipe.Setup(); err != nil {
		return nil, errors.Wrap(err, "failed to setup shell pipe")
	}

	return shellPipe, nil
}

// supervisePipe starts a pipe process as a goroutine that logs and restarts itself when an
// expected error occurs. On a runtime panic error, the program will crash gracefully, cleaning
// up temp files on the way out
func supervisePipe(
	ctx context.Context,
	cancel context.CancelFunc,
	cfg *Config, pipe messagepipes.ListenerAPI,
	pipeName string,
) {
	go func() {
		defer func() {
			if r := recover(); r != nil {
				gracefulExit(cfg, cancel, r)
			}
		}()
		for {
			if err := pipe.Listen(); err != nil {
				log.Println(
					errors.Wrap(
						err, fmt.Sprintf("listen failed for %s", pipeName)))
			}
			select {
			case <-ctx.Done():
				log.Println(fmt.Sprintf("listener %s exiting...", pipeName))
				return
			default:
			}
		}
	}()
}

// Trap watches for signals in order to exit gracefully with cleanup
func trap(cfg *Config, cancel context.CancelFunc) {
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

	errSignal := fmt.Errorf("encountered system signal: %v", <-killSignal)
	gracefulExit(cfg, cancel, errSignal)
}

// gracefulExit cleans up all temp files before the program exits
func gracefulExit(cfg *Config, cancel context.CancelFunc, reason interface{}) {
	cancel()
	log.Println("cleaning up tmp directory...")
	if err := utils.CleanDirectory(cfg.TempDirectory); err != nil {
		log.Fatal(err)
	}
	if reason != nil {
		log.Println(fmt.Sprintf("exiting due to: %v", reason))
	}

	os.Exit(1)
}
