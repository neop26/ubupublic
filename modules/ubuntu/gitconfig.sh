#!/bin/bash
# Configure Git identity and sensible defaults.
#
# Note: 'credential.helper store' writes credentials in PLAINTEXT to
# ~/.git-credentials. This module prefers libsecret, then cache.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Configuring Git..."

read -r -p "Enter Git user.name: " user
read -r -p "Enter Git user.email: " email

if [ -z "$user" ] || [ -z "$email" ]; then
  echo -e "${ERROR} Both name and email are required."
  exit 1
fi

backup_file "$HOME/.gitconfig"

git config --global user.name "$user"
git config --global user.email "$email"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.autocrlf input

# Prefer an encrypted store; fall back to an in-memory cache. Never plaintext.
if git help -a 2>/dev/null | grep -q credential-libsecret; then
  git config --global credential.helper libsecret
  echo -e "${OK} Credential helper: libsecret (encrypted keyring)"
elif [ -x /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret ]; then
  git config --global credential.helper \
    /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
  echo -e "${OK} Credential helper: libsecret (encrypted keyring)"
else
  git config --global credential.helper 'cache --timeout=3600'
  echo -e "${OK} Credential helper: cache (in memory, 1 hour)"
  echo -e "${NOTE} For persistent encrypted storage: sudo apt install libsecret-1-0 libsecret-1-dev"
fi

echo -e "${NOTE} Prefer SSH remotes over HTTPS to avoid storing credentials at all:"
echo -e "${NOTE}   ssh-keygen -t ed25519 -C \"\$email\"  &&  gh ssh-key add ~/.ssh/id_ed25519.pub"

echo
echo -e "${NOTE} Current global configuration:"
git config --global --list | sed 's/^/    /'

echo -e "${OK} Git configured."
exit 0
