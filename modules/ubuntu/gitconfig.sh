#!/bin/bash
# Source the global functions using absolute path
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "$SCRIPT_DIR/Global_functions.sh" ]; then
	source "$SCRIPT_DIR/Global_functions.sh"
fi

#!/bin/bash

read -p "Enter the Email Address for Git config (e.g., something@somethingcom): " email
read -p "Enter the User for Git config (e.g., someone): " user

# Backup current .gitconfig
sudo cp ~/.gitconfig ~/.gitconfig.backup
sudo rm -r ~/.gitconfig

# Generate new .gitconfig
cat << EOF | sudo tee ~/.gitconfig
[user]
	email = $email
	name = $user
[credential]
	helper = store
EOF
# Moved from install-scripts: gitconfig.sh (ubuntu-specific)
