#!/bin/bash

go build /Users/henry.warren/go/src/github.com/henrysdev/fisherman/fishermand/cmd/fishermand/main.go

mv main fishermand

trap "rm /tmp/fisherman/cmdpipe" EXIT

./fishermand
#go run /Users/henry.warren/go/src/github.com/henrysdev/fisherman/fishermand/cmd/fishermand/main.go

