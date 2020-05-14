#!/bin/bash

./scripts/install.sh
./scripts/exec.sh
trap ./scripts/uninstall.sh EXIT