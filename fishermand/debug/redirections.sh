#!/bin/bash

# Write stdout and stderr to log files
COMMAND_HERE > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)

# Write just stderr to log file
COMMAND_HERE 2> >(tee -a stderr.log >&2)
