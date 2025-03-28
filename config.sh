#!/bin/bash
# Central configuration file for Ubuntu setup scripts

# Script version
VERSION="2.0.0"

# Default timezone
DEFAULT_TIMEZONE="UTC"

# Default package groups
ESSENTIAL_PACKAGES=(
  curl
  wget
  git
  nano
  software-properties-common
  apt-transport-https
  gnupg
  ca-certificates
)

# Font packages
FONT_PACKAGES=(
  fonts-firacode
  fonts-font-awesome
  fonts-noto
  fonts-noto-cjk
  fonts-noto-color-emoji
)

# Network tools
NETWORK_PACKAGES=(
  net-tools
  nmap
  iperf3
  traceroute
)

# Development tools
DEV_PACKAGES=(
  build-essential
  cmake
  pkg-config
)

# Get the base directory
BASE_DIR="$(dirname "$(readlink -f "$0")")"

# Default installation directories
CONFIG_DIR="$HOME/.config"
SCRIPTS_DIR="$BASE_DIR/install-scripts"
ASSETS_DIR="$BASE_DIR/assets"
LOGS_DIR="$BASE_DIR/Install-Logs"

# Create logs directory if not exists
mkdir -p "$LOGS_DIR"

# Color definitions
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
ACTION="$(tput setaf 6)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"

# Function to log messages
log_message() {
  local type="$1"
  local message="$2"
  echo -e "${type} ${message}"
}

# Function to get current timestamp
get_timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

# Debug mode (set to true to enable more verbose output)
DEBUG_MODE=true

# Debug function
debug() {
  if [ "$DEBUG_MODE" = true ]; then
    log_message "${NOTE}" "DEBUG: $1"
  fi
}

# Print configuration information
if [ "$DEBUG_MODE" = true ]; then
  echo "Configuration loaded from: $0"
  echo "Base directory: $BASE_DIR"
  echo "Scripts directory: $SCRIPTS_DIR"
  echo "Assets directory: $ASSETS_DIR"
  echo "Logs directory: $LOGS_DIR"
fi
