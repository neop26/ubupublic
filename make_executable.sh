#!/bin/bash
# Script to make all scripts executable

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

echo "Making all scripts executable..."

# Make setup.sh executable
chmod +x "$SCRIPT_DIR/setup.sh"
echo "Made setup.sh executable"

# Make ubusetup.sh executable
chmod +x "$SCRIPT_DIR/ubusetup.sh"
echo "Made ubusetup.sh executable"

# Make scripts in install-scripts directory executable
for script in "$SCRIPT_DIR/install-scripts"/*.sh; do
  if [ -f "$script" ]; then
    chmod +x "$script"
    echo "Made $(basename "$script") executable"
  fi
done

echo "All scripts are now executable!"
