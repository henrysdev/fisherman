#!/bin/bash
mkdir "/tmp/.fisherman"
go build /Users/henry.warren/go/src/github.com/henrysdev/fisherman/fishermand/cmd/fishermand/main.go

mv main fishermand

trap "rm -rf /tmp/.fisherman/" EXIT

./fishermand
#go run /Users/henry.warren/go/src/github.com/henrysdev/fisherman/fishermand/cmd/fishermand/main.go

