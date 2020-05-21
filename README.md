[![Go Report Card](https://goreportcard.com/badge/github.com/henrysdev/fisherman)](https://goreportcard.com/report/github.com/henrysdev/fisherman)

# Fisherman
Fisherman is a project that aims to promote developer productivity and knowledge sharing among teams by collecting, analyzing, and correlating historical shell activity.

There are three main parts to the client program
1. The `fishermand` client daemon
2. The shell plugin (`ZSH` currently supported)
3. Backend web server (TODO)

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
1. `source $HOME/go/src/github.com/henrysdev/fisherman/shells/zsh/fisherman.plugin.zsh`
2. Open up a new shell to refresh changes

### Run the daemon in dev mode
Get the `fishermand` process running as follows:
1. Run `$HOME/go/src/github.com/henrysdev/fisherman/fishermand/scripts/rundev.sh` - this script installs and executes the `fishermand` process logging to stdout. On exit, this script will uninstall the fishermand program and its dependencies, leaving your local machine back in a clean state. Note that you will be prompted for your root password on install as the program uses /tmp/ as well as /usr/local/bin
2. Open up additional shells. Any commands you enter as well as any errors these commands produce should be observably logged in the first shell.
