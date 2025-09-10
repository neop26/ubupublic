# Bash script to install network tools

#!/bin/bash

# Source the global functions using absolute path
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "$SCRIPT_DIR/Global_functions.sh" ]; then
	source "$SCRIPT_DIR/Global_functions.sh"
fi
sudo apt install net-tools -y
# Moved from install-scripts: nettools.sh (ubuntu-specific)
