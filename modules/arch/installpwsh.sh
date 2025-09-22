#!/bin/bash
# Arch Linux: PowerShell installation note

SCRIPT_DIR="$(dirname \"$(readlink -f \"$0\")\")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${WARN} PowerShell is not in Arch official repos."
echo -e "${NOTE} Recommend installing via AUR helper (e.g., yay -S powershell-bin)."
exit 0

