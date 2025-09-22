#!/bin/bash
# Shared global functions for all OS types
# Centralized helpers for logging, prompts, package mgmt, downloads, etc.

set -o pipefail

# Determine repo base dir from this file's location (even when sourced)
CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${CORE_DIR}/.." && pwd)"

# Load canonical config
CONFIG_FILE="${BASE_DIR}/config.sh"
if [ -f "$CONFIG_FILE" ]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "[ERROR] Missing config: $CONFIG_FILE"
  return 1 2>/dev/null || exit 1
fi

# Ensure logs dir exists and define current log file
mkdir -p "$LOGS_DIR"
LOG="${LOGS_DIR}/install-$(date +%Y%m%d-%H%M%S).log"
touch "$LOG"

# --- UI helpers ---
ask_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  if [ "$default" = "y" ]; then
    prompt="$prompt [Y/n]"
  else
    prompt="$prompt [y/N]"
  fi
  while true; do
    read -p "$prompt " choice
    choice=${choice:-$default}
    case "$choice" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

show_progress() {
  local duration=${1:-2}
  local steps=20
  local sleep_duration
  sleep_duration=$(echo "scale=3; $duration / $steps" | bc 2>/dev/null || echo "0.1")
  echo -n "["
  for ((i=0; i<steps; i++)); do
    echo -n "#"
    sleep "$sleep_duration" 2>/dev/null || sleep 0.1
  done
  echo "] Done!"
}

check_command() {
  local status=$?
  if [ $status -eq 0 ]; then
    echo -e "${OK} Command executed successfully"
    return 0
  else
    echo -e "${ERROR} Command failed with exit code $status"
    return 1
  fi
}

debug_message() {
  echo -e "${NOTE} DEBUG: $*"
}

# --- System checks ---
check_system_requirements() {
  echo -e "${NOTE} Checking system requirements..."
  if [ "$EUID" -eq 0 ]; then
    echo -e "${ERROR} This script should not be run as root"
    return 1
  fi
  local available_space total_ram
  available_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
  if [ -n "$available_space" ] && [ "$available_space" -lt 5 ]; then
    echo -e "${WARN} Low disk space: ${available_space}GB available. Minimum: 5GB"
  else
    echo -e "${OK} Disk space check passed"
  fi
  total_ram=$(free -m | awk 'NR==2 {print $2}')
  if [ -n "$total_ram" ] && [ "$total_ram" -lt 2048 ]; then
    echo -e "${WARN} Low RAM: ${total_ram}MB. Minimum: 2048MB"
  else
    echo -e "${OK} RAM check passed"
  fi
  if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo -e "${OK} Internet connectivity available"
  else
    echo -e "${WARN} No internet connectivity detected"
    return 1
  fi
}

set_timezone() {
  local timezone="${1:-UTC}"
  echo -e "${NOTE} Setting timezone to $timezone"
  if sudo timedatectl set-timezone "$timezone" >>"$LOG" 2>&1; then
    echo -e "${OK} Timezone set to $timezone"
  else
    echo -e "${ERROR} Failed to set timezone to $timezone"
    return 1
  fi
}

# --- Apt helpers ---
command_exists() { command -v "$1" >/dev/null 2>&1; }

install_package() {
  local package="$1"
  if dpkg -l 2>/dev/null | grep -q -w "^ii  $package"; then
    echo -e "${OK} $package is already installed. Skipping."
    return 0
  fi
  echo -e "${NOTE} Installing $package ..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$package" >>"$LOG" 2>&1
  local status=$?
  if [ $status -eq 0 ]; then
    echo -e "${OK} $package installed"
  else
    echo -e "${ERROR} $package failed to install (see $LOG)"
  fi
  return $status
}

install_packages() {
  local failed=()
  for p in "$@"; do
    if ! install_package "$p"; then
      failed+=("$p")
    fi
  done
  if [ ${#failed[@]} -gt 0 ]; then
    echo -e "${WARN} Failed packages: ${failed[*]}"
    return 1
  fi
  echo -e "${OK} All packages installed"
}

uninstall_package() {
  local package="$1"
  if ! dpkg -l 2>/dev/null | grep -q -w "^ii  $package"; then
    echo -e "${NOTE} $package not installed, skipping"
    return 0
  fi
  echo -e "${NOTE} Uninstalling $package ..."
  sudo apt-get purge --autoremove -y "$package" >>"$LOG" 2>&1
  check_command
}

check_service() {
  local service="$1"
  if systemctl is-active --quiet "$service"; then
    echo -e "${OK} Service $service is running"
  else
    echo -e "${WARN} Service $service is not running"
    return 1
  fi
}

create_directory() {
  local dir="$1" perm="${2:-755}"
  if [ ! -d "$dir" ]; then
    echo -e "${NOTE} Creating directory $dir"
    mkdir -p "$dir" >>"$LOG" 2>&1 && chmod "$perm" "$dir" >>"$LOG" 2>&1
  fi
}

backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    local backup="${file}.backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${NOTE} Backing up $file -> $backup"
    cp "$file" "$backup" >>"$LOG" 2>&1
  fi
}

add_repository() {
  local repo="$1"
  echo -e "${NOTE} Adding APT repository: $repo"
  if sudo add-apt-repository -y "$repo" >>"$LOG" 2>&1; then
    sudo apt-get update >>"$LOG" 2>&1
    echo -e "${OK} Repository added"
  else
    echo -e "${ERROR} Failed to add repo: $repo"
    return 1
  fi
}

download_file() {
  local url="$1" output="${2:-$(basename "$url")}"
  echo -e "${NOTE} Downloading $url -> $output"
  if command_exists wget; then
    wget -q "$url" -O "$output" 2>>"$LOG" || return 1
  elif command_exists curl; then
    curl -fsSL "$url" -o "$output" 2>>"$LOG" || return 1
  else
    echo -e "${ERROR} Neither wget nor curl installed"
    return 1
  fi
  echo -e "${OK} Downloaded $output"
}
