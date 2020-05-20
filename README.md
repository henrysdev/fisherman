[![Go Report Card](https://goreportcard.com/badge/github.com/henrysdev/fisherman)](https://goreportcard.com/report/github.com/henrysdev/fisherman)

# Fisherman
Fisherman is a program for crowd-sourced programming help to enable you to fix errors without having to ever leave your terminal. It captures every error-producing command that you enter into your shell and sends this data to a web service that compares your errors against previously seen errors, and returns the best guess to fix.

There are three main parts to the client program
1. The `fishermand` local server
2. The shell plugin (`ZSH` currently supported)

## Fishermand
The `fishermand` process is a long-running background application that listens for incoming commands/errors from all active shells that you are using via IPC messages over a unix fifo pipe. The messages that this process consumes are sent to the server for further processing.

## Shell plugin
The shell plugin is responsible for publishing messages to the pipe that `fishermand` reads from. The shell plugin sends every command entered by the user along with any respective `STDERR` output while being completely out of the way of the user. The messages sent include the command, error output, and PID of the shell.

# Development
## Quick Start
### Install the Go package
Assuming you have Go installed, run the following command: `go get -u github.com/henrysdev/fisherman/...`

### Add the ZSH Plugin
Add the following line to your `.zshrc` file:
1. `source $HOME/go/src/github.com/fisherman/shells/zsh/fisherman.plugin.zsh`
2. Open up a new shell to refresh changes

### Run the daemon in dev mode
Get the `fishermand` process running as follows:
1. Open up a shell at the repository root and run `sudo ./scripts/rundev.sh` - this will start the `fishermand` client printing to stdout
2. Open up additional shells. Any commands you enter as well as any errors these commands produce should be observably logged in the first shell. 
