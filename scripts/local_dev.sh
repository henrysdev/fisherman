#!/bin/bash

docker run --rm -it --name fisherman \
  -v $PWD:/go/src/github.com/henrysdev/fisherman golang
