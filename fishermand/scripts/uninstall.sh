#!/bin/bash

# Uninstall config files and binary
function program_uninstall() {
    if [ -d /tmp/fisherman ]
        then
            echo "removing /tmp/fisherman directory"
            rm -rf /tmp/fisherman
    fi
    if [[ ( -d $HOME/.config ) && ( -d $HOME/.config/fisherman ) ]]
        then
            echo "removing ~/.config/fisherman directory"
            rm -rf $HOME/.config/fisherman
    fi
    if [ -f /usr/local/bin/fishermand ]
        then
            echo "removing /usr/local/bin/fishermand"
            rm -f /usr/local/bin/fishermand
    fi

    echo "removing /usr/local/bin/fishermand_booter"
    rm -f /usr/local/bin/fishermand_booter
}

# Remove launchd entry
function launchd_uninstall() {
    launchctl unload ~/Library/LaunchAgents/fishermand.plist
    rm ~/Library/LaunchAgents/fishermand.plist
}

echo "uninstalling fishermand..."
program_uninstall
