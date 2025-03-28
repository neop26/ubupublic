#!/bin/bash
# Advanced Ubuntu Setup Builder
# A modular, powerful and intuitive setup builder

# Source the configuration and global functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/install-scripts/Global_functions.sh"

# Clear the screen and show welcome message
clear
cat << "EOF"
 _   _ _                 _          _____      _               
| | | | |__  _   _ _ __ | |_ _   _ / ____|__ _| |_ _   _ _ __  
| | | | '_ \| | | | '_ \| __| | | | (___ / _` | __| | | | '_ \ 
| |_| | |_) | |_| | | | | |_| |_| |\___ \ (_| | |_| |_| | |_) |
 \___/|_.__/ \__,_|_| |_|\__|\__,_|____/\__,_|\__|\__,_| .__/ 
                                                       |_|     
EOF
echo
echo "Version: $VERSION"
echo "============================================================"
echo "Advanced Ubuntu System Setup Builder"
echo "============================================================"

# Check if script is run as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${ERROR} This script should not be executed as root!"
    exit 1
fi

# Create needed directories
create_directory "$LOGS_DIR"

# Define available modules
MODULES=(
    "system_update:Update system packages"
    "zsh:Install ZSH with Oh-My-ZSH"
    "network_tools:Install network diagnostic tools"
    "fonts:Install recommended fonts"
    "neofetch:Install and configure Neofetch"
    "azure_dev:Setup Azure development environment"
    "docker:Install Docker and Docker Compose"
    "nvidia_drivers:Install NVIDIA drivers"
    "static_ip:Configure static IP address"
    "cockpit:Setup Cockpit web console"
    "git_config:Configure Git settings"
    "node_js:Install Node.js and npm"
    "apache:Install Apache web server"
    "create_user:Create a new user account"
    "powershell:Install PowerShell"
)

# Function to display a selection menu
display_menu() {
    local title="$1"
    shift
    local options=("$@")
    local selected=()
    local choice
    
    echo -e "\n${ACTION} $title"
    echo "============================================================"
    
    for i in "${!options[@]}"; do
        echo "[$((i+1))] ${options[$i]}"
    done
    echo "[A] Select All"
    echo "[N] Select None"
    echo "[D] Done"
    echo "============================================================"
    
    while true; do
        read -p "Enter your selection (separate multiple choices with space): " -a choices
        
        # Check if choices contains "A" (Select All)
        if [[ " ${choices[*]} " == *" A "* ]]; then
            selected=("${!options[@]}")
            echo -e "${NOTE} All options selected!"
            break
        fi
        
        # Check if choices contains "N" (Select None)
        if [[ " ${choices[*]} " == *" N "* ]]; then
            selected=()
            echo -e "${NOTE} No options selected."
            break
        fi
        
        # Check if choices contains "D" (Done)
        if [[ " ${choices[*]} " == *" D "* ]]; then
            break
        fi
        
        # Process numeric selections
        for choice in "${choices[@]}"; do
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
                # Convert to zero-based index
                selected+=($((choice-1)))
            fi
        done
        
        break
    done
    
    # Return the selected indices
    echo "${selected[@]}"
}

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

# Display module menu
echo -e "${NOTE} Please select which components you want to install:"

# Extract descriptions for display
MODULE_DESCRIPTIONS=()
for module in "${MODULES[@]}"; do
    MODULE_DESCRIPTIONS+=("${module#*:}")
done

# Get selected modules
SELECTED_INDICES=$(display_menu "Available Modules" "${MODULE_DESCRIPTIONS[@]}")

# Prepare for execution
if [ -n "$SELECTED_INDICES" ]; then
    echo -e "${NOTE} Ready to install the following components:"
    for index in $SELECTED_INDICES; do
        module_name="${MODULES[$index]%%:*}"
        module_desc="${MODULES[$index]#*:}"
        echo -e "  - $module_desc"
    done
    
    # Confirm installation
    if ask_yes_no "Do you want to proceed with installation?" "y"; then
        # Execute selected modules
        for index in $SELECTED_INDICES; do
            module_name="${MODULES[$index]%%:*}"
            module_desc="${MODULES[$index]#*:}"
            
            echo -e "\n${ACTION} Installing: $module_desc"
            
            case "$module_name" in
                system_update)
                    "$SCRIPTS_DIR/update.sh"
                    ;;
                zsh)
                    "$SCRIPTS_DIR/zsh.sh"
                    ;;
                network_tools)
                    "$SCRIPTS_DIR/nettools.sh"
                    ;;
                fonts)
                    "$SCRIPTS_DIR/fonts.sh"
                    ;;
                neofetch)
                    "$SCRIPTS_DIR/neofetch.sh"
                    ;;
                azure_dev)
                    "$SCRIPTS_DIR/azuredev.sh"
                    ;;
                docker)
                    "$SCRIPTS_DIR/docker.sh"
                    ;;
                nvidia_drivers)
                    "$SCRIPTS_DIR/nvidiadrivers.sh"
                    ;;
                static_ip)
                    "$SCRIPTS_DIR/staticip.sh"
                    ;;
                cockpit)
                    "$SCRIPTS_DIR/cockpit.sh"
                    ;;
                git_config)
                    "$SCRIPTS_DIR/gitconfig.sh"
                    ;;
                node_js)
                    "$SCRIPTS_DIR/nodejsinstaller.sh"
                    ;;
                apache)
                    "$SCRIPTS_DIR/apache2.sh"
                    ;;
                create_user)
                    "$SCRIPTS_DIR/createuser.sh"
                    ;;
                powershell)
                    "$SCRIPTS_DIR/installpwsh.sh"
                    ;;
                *)
                    echo -e "${WARN} Unknown module: $module_name"
                    ;;
            esac
        done
        
        # Clean up
        if [ -e "JetBrainsMono.tar.xz" ]; then
            echo -e "${NOTE} Cleaning up temporary files..."
            rm JetBrainsMono.tar.xz
        fi
        
        echo -e "\n${OK} Setup completed successfully!"
        
        # Show system information
        if command_exists neofetch; then
            neofetch
        else
            echo -e "\n${NOTE} System Information:"
            echo "Hostname: $(hostname)"
            echo "Distribution: $(lsb_release -ds)"
            echo "Kernel: $(uname -r)"
            echo "Architecture: $(uname -m)"
            echo "CPU: $(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | sed 's/^ *//')"
            echo "Memory: $(free -h | awk '/Mem:/ {print $2}')"
            echo "Disk Space: $(df -h / | awk 'NR==2 {print $2}')"
        fi
    else
        echo -e "${NOTE} Installation canceled."
    fi
else
    echo -e "${NOTE} No modules selected. Exiting."
fi

echo -e "${NOTE} Thank you for using the Ubuntu Setup Builder!"
