#!/bin/bash
# Script to manually install packages that got stuck

# Source the global functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/Global_functions.sh"

# Check if a package name was provided
if [ $# -eq 0 ]; then
  echo -e "${ERROR} No package name provided!"
  echo "Usage: $0 <package_name>"
  exit 1
fi

package="$1"

echo -e "${NOTE} Attempting manual installation of $package..."

# First try to fix any interrupted installations
echo -e "${NOTE} Fixing any interrupted package installations..."
sudo dpkg --configure -a >> "$LOG" 2>&1

# Update apt cache
echo -e "${NOTE} Updating package lists..."
sudo apt update >> "$LOG" 2>&1

# Install the package with progress display
echo -e "${NOTE} Installing $package..."
echo -e "${NOTE} This is using direct apt-get command with interactive frontend"
sudo apt-get install -y "$package"

# Check if installation was successful
if dpkg -l | grep -q -w "^ii  $package" ; then
  echo -e "${OK} $package was installed successfully."
else
  echo -e "${ERROR} Failed to install $package."
  echo -e "${NOTE} You might want to try: sudo apt-get install -f"
fi

echo -e "${NOTE} Manual installation attempt completed."
