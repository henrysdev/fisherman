[![Go Report Card](https://goreportcard.com/badge/github.com/henrysdev/fisherman)](https://goreportcard.com/report/github.com/henrysdev/fisherman)

# Fisherman
Fisherman is a program for crowd-sourced programming help to enable you to fix errors without having to ever leave your terminal. It captures every error-producing command that you enter into your shell and sends this data to a web service that compares your errors against previously seen errors, and returns the best guess to fix.

There are three main parts to the client program
1. The `fishermand` local server
2. The shell plugin (`ZSH` currently supported)
3. The fisherman CLI utility

## Fishermand
The `fishermand` process is a long-running background application that listens for incoming commands/errors from all active shells that you are using via IPC messages sent from the shell plugin. The messages that this process consumes are sent to the server for further processing.

## Shell plugin
The shell plugin is responsible for publishing messages to the pipe that `fishermand` reads from. The shell plugin sends every command entered by the user along with any respective `STDERR` output while being completely out of the way of the user. The messages sent include the command, error output, and PID of the shell.

## Fisherman CLI
The CLI utility is currently a small program for starting/stopping/restarting `fishermand` properly.
This utility will eventually also allow the user to be able to view/edit/delete their command data as well.
