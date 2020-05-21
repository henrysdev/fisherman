#!/bin/bash
FISHERMAN_PATH=$HOME/go/src/github.com/henrysdev/fisherman

${FISHERMAN_PATH}/scripts/install.sh
${FISHERMAN_PATH}/scripts/exec.sh
trap $HOME/go/src/github.com/henrysdev/fisherman/scripts/uninstall.sh EXIT