#!/bin/bash

# Build and install the fishermand binary
function bin_install() {
    # TODO remove this step if not building from source
    go build fishermand/cmd/fishermand/main.go
    mv main /usr/local/bin/fishermand
    cp ./scripts/exec.sh /usr/local/bin/fishermand_booter
}

# Copy plist file to daemons dir and load
function launchd_install() {
    # TODO bundle plist with other install files
    cp ../install/macos/fishermand.plist $HOME/Library/LaunchAgents/fishermand.plist
    launchctl load $HOME/Library/LaunchAgents/fishermand.plist
}

# Create config file at user root and copy over default config
function config_install() {
    if [ ! -d $HOME/.config ]
        then
            mkdir $HOME/.config/
    fi
    if [ ! -d $HOME/.config/fisherman ]
        then
            mkdir $HOME/.config/fisherman
    fi
    if [ ! -f $HOME/.config/fisherman/config.yml ]
        then # TODO bundle config.yml with other install files
            cp fishermand/config/config.yml $HOME/.config/fisherman/config.yml
    fi
}

bin_install
config_install
