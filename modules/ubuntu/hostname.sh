
#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"
# Script to configure a hostname on Ubuntu

# Prompt for Hostname
read -r -p "Enter the new hostname for this server : " hostname

# Check if hostname is not empty
if [ -n "$hostname" ]; then
	sudo hostnamectl set-hostname "$hostname"
	echo "Hostname has been set to $hostname."
else
	echo "No hostname entered. Skipping hostname configuration."
fi
# Moved from install-scripts: hostname.sh (ubuntu-specific)
