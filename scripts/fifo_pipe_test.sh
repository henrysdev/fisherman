#!/bin/bash

if [ -p fisherman_fifo ]
  then
    echo "fisherman_fifo named pipe exists."
    echo "[0] writing to pipe..."
    echo "fake command" > fisherman_fifo
    sleep 0.1
    echo "[1] writing to pipe..."
    echo "another fake command" > fisherman_fifo
    echo "unblocked"
fi
