package main

import (
	"log"
	"os"

	"github.com/henrysdev/fisherman/fishermand/pkg/application"
)

func main() {
	configFilepath := os.Getenv("FISHERMAN_PATH")
	if configFilepath == "" {
		log.Println("Env var FISHERMAN_PATH not set, looking for config at $HOME/.fisherman/config.yml")
		configFilepath = os.Getenv("$HOME") + "/.fisherman/config.yml"
	}
	application.Init(configFilepath)
}
