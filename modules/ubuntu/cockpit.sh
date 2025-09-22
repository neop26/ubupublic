#!/bin/bash
# Install Cockpit web console

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck disable=SC1090
source "$REPO_DIR/core/Global_functions.sh"

sudo apt-get update >>"$LOG" 2>&1
install_package cockpit
