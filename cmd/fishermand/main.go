package main

import (
	"github.com/henrysdev/fisherman/pkg/client"
)

func main() {
	cfg, err := client.ParseFlags()
	if err != nil {
		panic(err)
	}
	fisherman := client.NewFisherman(cfg)
	fisherman.Start()
}
