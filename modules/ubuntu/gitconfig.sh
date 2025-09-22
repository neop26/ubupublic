#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

read -r -p "Enter Git user.name: " user
read -r -p "Enter Git user.email: " email

# Backup current .gitconfig (if exists)
if [ -f "$HOME/.gitconfig" ]; then
  cp "$HOME/.gitconfig" "$HOME/.gitconfig.backup-$(date +%Y%m%d-%H%M%S)"
fi

cat > "$HOME/.gitconfig" << EOF
[user]
    name = $user
    email = $email
[credential]
    helper = store
EOF
# Moved from install-scripts: gitconfig.sh (ubuntu-specific)
