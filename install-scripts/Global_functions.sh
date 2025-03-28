#!/bin/bash
# 💫 Enhanced Global Functions for Scripts 💫

# Source the configuration file if it exists
CONFIG_FILE="$(dirname "$(dirname "$(readlink -f "$0")")")/config.sh"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Config file not found. Creating default config..."
  mkdir -p "$(dirname "$CONFIG_FILE")"
  cat > "$CONFIG_FILE" << 'EOL'
#!/bin/bash
# Default configuration

# Create Directory for Install Logs
LOGS_DIR="$(dirname "$(readlink -f "$0")")/Install-Logs"
mkdir -p "$LOGS_DIR"

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
ACTION="$(tput setaf 6)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"
EOL
  source "$CONFIG_FILE"
fi

# Create logs directory
mkdir -p "$LOGS_DIR"

# Set current log file
LOG="$LOGS_DIR/install-$(date +%Y%m%d-%H%M%S).log"
touch "$LOG"

# Function for displaying progress bar
show_progress() {
  local duration=$1
  local steps=20
  local sleep_duration=$(bc <<< "scale=3; $duration / $steps")
  
  echo -n "["
  for ((i=0; i<steps; i++)); do
    echo -n "#"
    sleep "$sleep_duration"
  done
  echo "] Done!"
}

# Function for checking command status
check_command() {
  if [ $? -eq 0 ]; then
    echo -e "${OK} Command executed successfully"
  else
    echo -e "${ERROR} Command failed with exit code $?"
    return 1
  fi
}

# Function for installing packages with progress tracking
install_package() {
  local package="$1"
  # Checking if package is already installed
  if dpkg -l | grep -q -w "^ii  $package" ; then
    echo -e "${OK} $package is already installed. Skipping..."
  else
    # Package not installed
    echo -e "${NOTE} Installing $package ..."
    
    # Start installation with output redirection to log
    sudo apt-get install -y "$package" >> "$LOG" 2>&1 &
    
    # Get PID of the last background process
    local pid=$!
    
    # Show spinner while waiting for installation
    local spin=('-' '\' '|' '/')
    local i=0
    while kill -0 $pid 2>/dev/null; do
      echo -ne "\r[ ${spin[$i]} ] Installing..."
      i=$(( (i+1) % 4 ))
      sleep 0.5
    done
    
    # Check if installation was successful
    wait $pid
    if [ $? -eq 0 ]; then
      echo -e "\r${OK} $package was installed successfully."
    else
      echo -e "\r${ERROR} $package failed to install. Check the log: $LOG"
      return 1
    fi
  fi
}

# Function for installing multiple packages
install_packages() {
  local packages=("$@")
  local failed=()
  
  for package in "${packages[@]}"; do
    if ! install_package "$package"; then
      failed+=("$package")
    fi
  done
  
  if [ ${#failed[@]} -eq 0 ]; then
    echo -e "${OK} All packages installed successfully."
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
    local spin=('-' '\' '|' '/')
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
    echo -e "${NOTE} $package is not installed. Skipping..."
  fi
}

# Function to check if a service is running
check_service() {
  local service="$1"
  if systemctl is-active --quiet "$service"; then
    echo -e "${OK} Service $service is running"
    return 0
  else
    echo -e "${WARN} Service $service is not running"
    return 1
  fi
}

# Function to create a directory with proper permissions
create_directory() {
  local dir="$1"
  local perm="${2:-755}"
  
  if [ ! -d "$dir" ]; then
    echo -e "${NOTE} Creating directory $dir"
    mkdir -p "$dir" >> "$LOG" 2>&1
    chmod "$perm" "$dir" >> "$LOG" 2>&1
    echo -e "${OK} Directory $dir created with permissions $perm"
  else
    echo -e "${NOTE} Directory $dir already exists"
  fi
}

# Function to backup a file
backup_file() {
  local file="$1"
  local backup="${file}.backup-$(date +%Y%m%d-%H%M%S)"
  
  if [ -f "$file" ]; then
    echo -e "${NOTE} Backing up $file to $backup"
    cp "$file" "$backup" >> "$LOG" 2>&1
    echo -e "${OK} Backup created: $backup"
  else
    echo -e "${WARN} File $file does not exist, cannot create backup"
    return 1
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to add a repository
add_repository() {
  local repo="$1"
  
  echo -e "${NOTE} Adding repository: $repo"
  sudo add-apt-repository -y "$repo" >> "$LOG" 2>&1
  
  if [ $? -eq 0 ]; then
    echo -e "${OK} Repository added successfully"
    sudo apt update >> "$LOG" 2>&1
  else
    echo -e "${ERROR} Failed to add repository: $repo"
    return 1
  fi
}

# Function to check system requirements
check_system_requirements() {
  echo -e "${NOTE} Checking system requirements..."
  
  # Check if running as root
  if [ "$EUID" -eq 0 ]; then
    echo -e "${ERROR} This script should not be run as root"
    return 1
  fi
  
  # Check available disk space (minimum 5GB)
  local available_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
  if [ "$available_space" -lt 5 ]; then
    echo -e "${WARN} Low disk space: ${available_space}GB available. Minimum recommended: 5GB"
  else
    echo -e "${OK} Sufficient disk space: ${available_space}GB available"
  fi
  
  # Check RAM (minimum 2GB)
  local total_ram=$(free -m | awk 'NR==2 {print $2}')
  if [ "$total_ram" -lt 2048 ]; then
    echo -e "${WARN} Low RAM: ${total_ram}MB available. Minimum recommended: 2048MB"
  else
    echo -e "${OK} Sufficient RAM: ${total_ram}MB available"
  fi
  
  # Check internet connection
  if ping -c 1 google.com &> /dev/null; then
    echo -e "${OK} Internet connection available"
  else
    echo -e "${WARN} No internet connection detected"
    return 1
  fi
  
  echo -e "${OK} System requirements check completed"
}

# Function to set system timezone
set_timezone() {
  local timezone="${1:-UTC}"
  
  echo -e "${NOTE} Setting timezone to $timezone"
  sudo timedatectl set-timezone "$timezone" >> "$LOG" 2>&1
  
  if [ $? -eq 0 ]; then
    echo -e "${OK} Timezone set to $timezone"
  else
    echo -e "${ERROR} Failed to set timezone to $timezone"
    return 1
  fi
}

# Function to download a file with progress
download_file() {
  local url="$1"
  local output="${2:-$(basename "$url")}"
  
  echo -e "${NOTE} Downloading $url to $output"
  
  if command_exists wget; then
    wget --progress=bar:force "$url" -O "$output" 2>&1 | tee -a "$LOG"
  elif command_exists curl; then
    curl -L --progress-bar "$url" -o "$output" 2>&1 | tee -a "$LOG"
  else
    echo -e "${ERROR} Neither wget nor curl is installed"
    return 1
  fi
  
  if [ -f "$output" ]; then
    echo -e "${OK} Downloaded $output successfully"
  else
    echo -e "${ERROR} Failed to download $output"
    return 1
  fi
}