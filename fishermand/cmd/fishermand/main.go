package main

import (
	"os"

	"github.com/henrysdev/fisherman/fishermand/pkg/application"
)

func main() {
	// TODO use $HOME
	configFilepath := os.Getenv("FISHERMAN_PATH")
	application.Init(configFilepath)
}
