#!/bin/bash
# Deprecated: Neofetch is replaced by Fastfetch.
# This wrapper installs and configures Fastfetch instead.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

echo -e "${NOTE} Neofetch module is deprecated. Installing Fastfetch instead..."
"$SCRIPT_DIR/fastfetch.sh"
