package main

import (
	"log"
	"os/user"

	"github.com/henrysdev/fisherman/fishermand/pkg/application"
)

func main() {
	usr, err := user.Current()
	if err != nil {
		log.Fatal(err)
	}
	configFilepath := usr.HomeDir + "/.config/fisherman/config.yml"
	application.Init(configFilepath)
}
