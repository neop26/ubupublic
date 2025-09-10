#!/bin/bash

# Source the global functions using absolute path
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "$SCRIPT_DIR/Global_functions.sh" ]; then
	source "$SCRIPT_DIR/Global_functions.sh"
fi
sudo apt install nodejs -y && sudo apt install npm -y
# Moved from install-scripts: nodejsinstaller.sh (ubuntu-specific)
