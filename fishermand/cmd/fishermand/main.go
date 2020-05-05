package main

import (
	"os"

	"github.com/henrysdev/fisherman/fishermand/pkg/application"
)

func main() {
	configFilepath := os.Getenv("FISHERMAN_PATH")
	application.Run(configFilepath)
}
