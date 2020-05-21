#!/bin/bash
FISHERMAN_PATH=$HOME/go/src/github.com/henrysdev/fisherman

${FISHERMAN_PATH}/fishermand/scripts/install.sh
${FISHERMAN_PATH}/fishermand/scripts/exec.sh
trap ${FISHERMAN_PATH}/fishermand/scripts/uninstall.sh EXIT