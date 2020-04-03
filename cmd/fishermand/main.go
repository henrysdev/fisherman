package main

import (
	"github.com/henrysdev/fisherman/pkg/config"
	"github.com/henrysdev/fisherman/pkg/fisherman"
)

func main() {
	cfg, err := config.ParseFlags()
	if err != nil {
		panic(err)
	}
	fisherman := fisherman.NewFisherman(cfg)
	fisherman.Start()
}
