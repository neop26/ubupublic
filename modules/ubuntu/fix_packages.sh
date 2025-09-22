#!/bin/bash
# Script to fix package installation issues

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Starting package system repair..."

# Fix any broken package installations
echo -e "${NOTE} Fixing interrupted package installations..."
sudo dpkg --configure -a >> "$LOG" 2>&1

# Fix broken dependencies
echo -e "${NOTE} Fixing broken dependencies..."
sudo apt-get --fix-broken install -y >> "$LOG" 2>&1

# Update package lists
echo -e "${NOTE} Updating package lists..."
sudo apt-get update >> "$LOG" 2>&1

# Check for and resolve any conflicts
echo -e "${NOTE} Checking for package conflicts..."
sudo apt-get check >> "$LOG" 2>&1

# Clean package cache
echo -e "${NOTE} Cleaning package cache..."
sudo apt-get clean >> "$LOG" 2>&1

# Reinstall any partially installed packages
if [ $# -gt 0 ]; then
	echo -e "${NOTE} Attempting to reinstall specified packages: $@"
	for package in "$@"; do
		echo -e "${NOTE} Reinstalling $package..."
		sudo apt-get install --reinstall -y "$package" >> "$LOG" 2>&1
		if [ $? -eq 0 ]; then
			echo -e "${OK} Successfully reinstalled $package"
		else
			echo -e "${ERROR} Failed to reinstall $package"
		fi
	done
fi

echo -e "${OK} Package system repair completed!"
echo -e "${NOTE} If you were experiencing issues with specific packages,"
echo -e "${NOTE} you may now try installing them again using setup.sh"
# Moved from install-scripts: fix_packages.sh (ubuntu-specific)
