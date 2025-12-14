#!/bin/bash
# Canonical configuration for setup scripts

# Versioning
VERSION="2.2.0"

# Default timezone
# Set to Pacific/Auckland by default (change if you prefer another timezone)
DEFAULT_TIMEZONE="Pacific/Auckland"

# Compute repo base directory robustly
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Directories
MODULES_DIR="$BASE_DIR/modules"
ASSETS_DIR="$BASE_DIR/assets"
LOGS_DIR="$BASE_DIR/Install-Logs"
CONFIG_DIR="$HOME/.config"
mkdir -p "$LOGS_DIR"

# Package groups
ESSENTIAL_PACKAGES=(
  curl wget git nano software-properties-common apt-transport-https gnupg ca-certificates
)
FONT_PACKAGES=(
  fonts-firacode fonts-font-awesome fonts-noto fonts-noto-cjk fonts-noto-color-emoji
)
NETWORK_PACKAGES=(
  net-tools nmap iperf3 traceroute
)
DEV_PACKAGES=(
  build-essential cmake pkg-config
)

# Colors
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
ACTION="$(tput setaf 6)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"

# Debug utilities
DEBUG_MODE=true
log_message() { echo -e "$1 $2"; }
get_timestamp() { date +"%Y-%m-%d %H:%M:%S"; }
debug() { [ "$DEBUG_MODE" = true ] && log_message "${NOTE}" "DEBUG: $*"; }

[ "$DEBUG_MODE" = true ] && {
  echo "Config loaded: $BASE_DIR/config.sh"
  echo "Modules: $MODULES_DIR"
  echo "Assets:  $ASSETS_DIR"
  echo "Logs:    $LOGS_DIR"
}
