#!/bin/bash

# Uninstall config files and binary
function program_uninstall() {
    if [ -d /tmp/fisherman ]
        then
            sudo rm -rf /tmp/fisherman
    fi
    if [[ ( -d $HOME/.config ) && ( -d $HOME/.config/fisherman ) ]]
        then
            sudo rm -rf $HOME/.config/fisherman
    fi
    if [ -f /usr/local/bin/fishermand ]
        then
            sudo rm -f /usr/local/bin/fishermand
    fi
    sudo rm -f /usr/local/bin/fishermand_booter
}

# Remove launchd entry
function launchd_uninstall() {
    launchctl unload ~/Library/LaunchAgents/fishermand.plist
    rm ~/Library/LaunchAgents/fishermand.plist
}

program_uninstall
