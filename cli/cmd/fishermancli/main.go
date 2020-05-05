package main

import (
	"flag"
	"fmt"

	"github.com/henrysdev/fisherman/cli/pkg/cli"
)

func main() {
	action := flag.String("action", "", "[start | stop | restart]")
	fifoPipe := flag.String("pipe", "/tmp/fisherman_fifo", "location of fifo pipe")
	flag.Parse()

	client := &cli.CLI{
		FifoPipe: *fifoPipe,
	}
	switch *action {
	case "start":
		if err := client.Start(); err != nil {
			fmt.Println(err)
		}
	case "stop":
		if err := client.Stop(); err != nil {
			fmt.Println(err)
		}
	case "restart":
		if err := client.Restart(); err != nil {
			fmt.Println(err)
		}
	default:
		fmt.Println(fmt.Errorf("Unrecognized option %v", *action))
	}
}
