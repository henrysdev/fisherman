#!/bin/bash

trap "rm fisherman_fifo" EXIT
go run /Users/henry.warren/go/src/github.com/henrysdev/fisherman/cmd/fishermand/main.go
