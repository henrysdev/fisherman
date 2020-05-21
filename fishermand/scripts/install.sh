#!/bin/bash

# User path constant
FISHERMAN_PATH=$HOME/go/src/github.com/henrysdev/fisherman

# Build and install the fishermand binary
function bin_install() {
    echo "building executable from go source"
    go build ${FISHERMAN_PATH}/fishermand/cmd/fishermand/main.go
    
    echo "moving binaries to /usr/local/bin (requires root)"
    sudo mv main /usr/local/bin/fishermand
    sudo cp ${FISHERMAN_PATH}/fishermand/scripts/exec.sh /usr/local/bin/fishermand_booter
}

# Copy plist file to daemons dir and load
function launchd_install() {
    # TODO bundle plist with other install files
    cp ${FISHERMAN_PATH}/fishermand/install/macos/fishermand.plist $HOME/Library/LaunchAgents/fishermand.plist
    launchctl load $HOME/Library/LaunchAgents/fishermand.plist
}

# Create config file at user root and copy over default config
function config_install() {
    echo "installing configs to ~/.config/fisherman/"
    if [ ! -d $HOME/.config ]
        then
            mkdir $HOME/.config/
    fi
    if [ ! -d $HOME/.config/fisherman ]
        then
            mkdir $HOME/.config/fisherman
    fi
    if [ ! -f $HOME/.config/fisherman/config.yml ]
        then
            cp ${FISHERMAN_PATH}/fishermand/config/config.yml $HOME/.config/fisherman/config.yml
    fi
}

echo "installing fishermand..."
bin_install
config_install
