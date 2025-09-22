#!/bin/bash
# Arch Linux: Create a new user with wheel group access

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

read -r -p "Enter the new username: " username
if [ -z "$username" ]; then
  echo -e "${ERROR} Username cannot be empty"; exit 1
fi
read -r -s -p "Enter the password: " password; echo

sudo useradd -m -U -G wheel -s /bin/bash "$username"
echo "$username:$password" | sudo chpasswd
echo -e "${NOTE} Ensure sudoers permits wheel group (check /etc/sudoers)."
echo -e "${OK} User $username created and added to wheel group."

