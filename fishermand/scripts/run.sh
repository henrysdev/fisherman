#!/bin/bash

trap "rm /tmp/fisherman/cmdpipe" EXIT
go run /Users/henry.warren/go/src/github.com/henrysdev/fisherman/fishermand/cmd/fishermand/main.go
