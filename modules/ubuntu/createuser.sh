#!/bin/bash
# Create a new sudo-capable user

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

read -r -p "Enter the new username: " username
if [ -z "$username" ]; then
  echo -e "${ERROR} Username cannot be empty"
  exit 1
fi
read -r -s -p "Enter the password: " password
echo

sudo adduser --gecos "" "$username"
echo "$username:$password" | sudo chpasswd
sudo usermod -aG sudo "$username"

echo "User $username created and added to the sudo group."
# Moved from install-scripts: createuser.sh (ubuntu-specific)
