# Moved from install-scripts: cockpit.sh (ubuntu-specific)
#!/bin/bash
sudo apt update

# Source the global functions using absolute path
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "$SCRIPT_DIR/Global_functions.sh" ]; then
	source "$SCRIPT_DIR/Global_functions.sh"
fi
sudo apt -y install cockpit
