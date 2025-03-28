#!/bin/bash
# Transitional script for backward compatibility
# This script now redirects to the new setup.sh

echo "ubusetup.sh is deprecated and has been replaced by setup.sh"
echo "Redirecting to setup.sh..."
sleep 2

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Run the new setup script
"$SCRIPT_DIR/setup.sh"
