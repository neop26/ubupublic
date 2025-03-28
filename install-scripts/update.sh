#!/bin/bash
# Enhanced system update script

# Source the global functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/Global_functions.sh"

echo -e "${NOTE} Starting system update process..."

# Check system requirements
check_system_requirements

# Create a detailed log header
{
  echo "===================================================="
  echo "System Update Log - $(date)"
  echo "System: $(lsb_release -ds)"
  echo "Kernel: $(uname -r)"
  echo "===================================================="
} >> "$LOG"

echo -e "${NOTE} Updating package lists..."
sudo apt update >> "$LOG" 2>&1
check_command

echo -e "${NOTE} Installing essential packages..."
install_packages "${ESSENTIAL_PACKAGES[@]}"

echo -e "${NOTE} Setting timezone to ${DEFAULT_TIMEZONE}..."
set_timezone "${DEFAULT_TIMEZONE}"

echo -e "${NOTE} Upgrading packages..."
sudo apt upgrade -y >> "$LOG" 2>&1
check_command

echo -e "${NOTE} Cleaning up unnecessary packages..."
sudo apt autoremove -y >> "$LOG" 2>&1
sudo apt autoclean -y >> "$LOG" 2>&1
check_command

# Install system monitors one by one with error handling
echo -e "${NOTE} Installing system monitoring tools..."
for tool in htop ncdu neofetch; do
  if ! install_package "$tool"; then
    echo -e "${WARN} Failed to install $tool, continuing with other packages..."
  fi
done

echo -e "${OK} System update completed successfully!"
echo -e "${NOTE} Log saved to: $LOG"

# Show summary information
echo -e "\n${ACTION} System Update Summary:"
echo -e "${NOTE} Date: $(date)"
echo -e "${NOTE} System: $(lsb_release -ds)"
echo -e "${NOTE} Kernel: $(uname -r)"
echo -e "${NOTE} Available disk space: $(df -h / | awk 'NR==2 {print $4}')"
echo -e "${NOTE} Memory: $(free -h | awk 'NR==2 {print $4}') available out of $(free -h | awk 'NR==2 {print $2}')"