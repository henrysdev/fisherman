package main

import (
	"flag"
	"fmt"

	"github.com/henrysdev/fisherman/cli/pkg/cli"
)

const (
	shPipe  = "/tmp/fisherman/cmdpipe"
	sysPipe = "/tmp/fisherman/syspipe"
	binLoc  = "/Users/henry.warren/go/src/github.com/henrysdev/fisherman/scripts/run.sh"
)

func main() {
	action := flag.String("action", "", "[start | stop | restart]")
	shellPipe := flag.String("shell_pipe", shPipe, "location of shell pipe")
	systemPipe := flag.String("system_pipe", sysPipe, "location of system pipe")
	binLocation := flag.String("bin_location", binLoc, "location of daemon binary")
	flag.Parse()

	client := &cli.CLI{
		ShellPipe:   *shellPipe,
		SystemPipe:  *systemPipe,
		BinLocation: *binLocation,
	}
	switch *action {
	case "start":
		client.Start()
	case "stop":
		client.Stop()
	case "restart":
		client.Restart()
	default:
		fmt.Println(fmt.Errorf("Unrecognized option %v", *action))
	}
}
