package main

import (
	"log"
	"os"
	"os/user"

	"github.com/henrysdev/fisherman/fishermand/pkg/application"
)

func main() {
	configFilepath := ""
	if len(os.Args) > 1 {
		configFilepath = os.Args[1]
	} else {
		usr, err := user.Current()
		if err != nil {
			log.Fatal(err)
		}
		configFilepath = usr.HomeDir + "/.config/fisherman/config.yml"
	}
	application.Init(configFilepath)
}
