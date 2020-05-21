#!/bin/bash

FISHERMAN_PATH=$HOME/go/src/github.com/henrysdev/fisherman

# comment back in launchctl install/uninstall functions to use
${FISHERMAN_PATH}/fishermand/scripts/uninstall.sh
${FISHERMAN_PATH}/fishermand/scripts/install.sh
launchctl start fishermand