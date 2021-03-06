#!/bin/bash

# Garbage collect left over processes and files
function cleanup() {
    echo "cleaning up temp files..."
    if [ -d /tmp/fisherman/ ]
        then
            rm -rf /tmp/fisherman/
    fi
}
trap cleanup EXIT

# Execute the fishermand binary
function fishermand() {
    # Create fisherman tmp dir if it does not already exist
    if [ ! -d /tmp/fisherman ]
        then
            mkdir /tmp/fisherman
    fi

    # If the expected binary exists, run it
    if [ -f /usr/local/bin/fishermand ]
        then
            /usr/local/bin/fishermand
        else
            echo "could not find executable at /usr/local/bin/fishermand"
    fi
}

echo "executing fishermand..."
fishermand
