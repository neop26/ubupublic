#!/bin/bash
# 💫 Enhanced Global Functions for Scripts 💫

# Handle possible errors in a safe way
set -o pipefail

# Source the configuration file if it exists
CONFIG_FILE="$(dirname \"$(dirname \"$(readlink -f \"$0\")\")\")/config.sh"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Config file not found. Creating default config..."
  mkdir -p "$(dirname "$CONFIG_FILE")"
  cat > "$CONFIG_FILE" << 'EOL'
#!/bin/bash
# Default configuration

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
)

# Default installation directories
CONFIG_DIR="$HOME/.config"
SCRIPTS_DIR="$(dirname \"$(readlink -f \"$0\")\")/install-scripts"
ASSETS_DIR="$(dirname \"$(readlink -f \"$0\")\")/assets"
LOGS_DIR="$(dirname \"$(readlink -f \"$0\")\")/Install-Logs"

# Create logs directory if not exists
mkdir -p "$LOGS_DIR"

# Color definitions
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
ACTION="$(tput setaf 6)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"
EOL
  source "$CONFIG_FILE"
fi

# Function to handle errors
handle_error() {
  echo -e "${ERROR} An error occurred on line $1"
  echo "Please check the logs for more information."
  exit 1
}

# Set up error handling (but don't exit on all errors, to allow the script to continue)
# trap 'handle_error $LINENO' ERR

# Create logs directory
mkdir -p "$LOGS_DIR"

# Set current log file
LOG="$LOGS_DIR/install-$(date +%Y%m%d-%H%M%S).log"
touch "$LOG"

# Function to ask yes/no question
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
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function for displaying progress bar
show_progress() {
  local duration=$1
  local steps=20
  local sleep_duration=$(echo "scale=3; $duration / $steps" | bc 2>/dev/null || echo "0.1")
  
  echo -n "["
  for ((i=0; i<steps; i++)); do
    echo -n "#"
    sleep "$sleep_duration" 2>/dev/null || sleep 0.1
  done
  echo "] Done!"
}

# Function for checking command status
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

# Function for installing packages with progress tracking
install_package() {
  local package="$1"
  local timeout=300  # 5-minute timeout for package installation
  
  # Checking if package is already installed
  if dpkg -l 2>/dev/null | grep -q -w "^ii  $package" ; then
    echo -e "${OK} $package is already installed. Skipping..."
    return 0
  fi
  
  # Package not installed
  echo -e "${NOTE} Installing $package ..."
  
  # Start installation without a background process - more reliable
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$package" >> "$LOG" 2>&1
  local status=$?
  
  if [ $status -eq 0 ]; then
    echo -e "${OK} $package was installed successfully."
    return 0
  else
    echo -e "${ERROR} $package failed to install. Check the log: $LOG"
    return 1
  fi
}

# Function for installing multiple packages
install_packages() {
  local packages=("$@")
  local failed=()
  
  if [ ${#packages[@]} -eq 0 ]; then
    echo -e "${WARN} No packages specified for installation."
    return 0
  fi
  
  for package in "${packages[@]}"; do
    if ! install_package "$package"; then
      failed+=("$package")
    fi
  done
  
  if [ ${#failed[@]} -eq 0 ]; then
    echo -e "${OK} All packages installed successfully."
    return 0
  else
    echo -e "${WARN} The following packages failed to install: ${failed[*]}"
    return 1
  fi
}

# Function to safely uninstall a package
uninstall_package() {
  local package="$1"
  # Check if package is installed
  if dpkg -l | grep -q -w "^ii  $package" ; then
    # Package is installed, attempt to uninstall
    echo -e "${NOTE} Uninstalling $package ..."
    
    # Start uninstallation with output redirection to log
    sudo apt-get purge --autoremove -y "$package" >> "$LOG" 2>&1 &
    
    # Get PID of the last background process
    local pid=$!
    
    # Show spinner while waiting for uninstallation
    local spin=('-' '\\' '|' '/')
    local i=0
    while kill -0 $pid 2>/dev/null; do
      echo -ne "\r[ ${spin[$i]} ] Uninstalling..."
      i=$(( (i+1) % 4 ))
      sleep 0.5
    done
    
    # Check if uninstallation was successful
    wait $pid
    if [ $? -eq 0 ]; then
      echo -e "\r${OK} $package was uninstalled successfully."
    else
      echo -e "\r${ERROR} $package failed to uninstall. Check the log: $LOG"
      return 1
    fi
  else
    echo -e "${WARN} $package is not installed. Skipping..."
  fi
}
