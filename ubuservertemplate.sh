# Bash script to install applications for a fresh Ubuntu CT

#!/bin/bash

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting......."
    exit 1
fi

clear

printf "\n%.0s" {1..3}         _             _            _      
echo "         /\ \     _    /\ \         /\ \       "
echo "        /  \ \   /\_\ /  \ \       /  \ \      "
echo "       / /\ \ \_/ / // /\ \ \     / /\ \ \     "
echo "      / / /\ \___/ // / /\ \_\   / / /\ \ \    "
echo "     / / /  \/____// /_/_ \/_/  / / /  \ \_\   "
echo "    / / /    / / // /____/\    / / /   / / /   "
echo "   / / /    / / // /\____\/   / / /   / / /    "
echo "  / / /    / / // / /______  / / /___/ / /     "
echo " / / /    / / // / /_______\/ / /____\/ /      "
echo " \/_/     \/_/ \/__________/\/_________/       "
printf "\n%.0s" {1..2}                                      


# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Function to colorize prompts
colorize_prompt() {
    local color="$1"
    local message="$2"
    echo -n "${color}${message}$(tput sgr0)"
}

# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S).log"

# Define the directory where your scripts are located
script_directory=install-scripts

# Function to ask a yes/no question and set the response in a variable
ask_yes_no() {
    while true; do
        read -p "$(colorize_prompt "$CAT"  "$1 (y/n): ")" choice
        case "$choice" in
            [Yy]* ) eval "$2='Y'"; return 0;;
            [Nn]* ) eval "$2='N'"; return 1;;
            * ) echo "Please answer with y or n.";;
        esac
    done
}

# Function to ask a custom question with specific options and set the response in a variable
ask_custom_option() {
    local prompt="$1"
    local valid_options="$2"
    local response_var="$3"

    while true; do
        read -p "$(colorize_prompt "$CAT"  "$prompt ($valid_options): ")" choice
        if [[ " $valid_options " == *" $choice "* ]]; then
            eval "$response_var='$choice'"
            return 0
        else
            echo "Please choose one of the provided options: $valid_options"
        fi
    done
}
# Function to execute a script if it exists and make it executable
execute_script() {
    local script="$1"
    local script_path="$script_directory/$script"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            "$script_path"
        else
            echo "Failed to make script '$script' executable."
        fi
    else
        echo "Script '$script' not found in '$script_directory'."
    fi
}

# Collect user responses to all questions
printf "\n"
ask_yes_no "-Shall I update this system" update
printf "\n"

### Update and Upgrade
##sudo apt update && sudo apt upgrade -y
##
### Add Net Tools
##sudo apt install net-tools -y
##
### Install Neofetch
##sudo apt install neofetch -y
##
### Install Htop
##sudo apt install htop -y
##
### Ability to deploy repository
##sudo apt install --reinstall software-properties-common -y
##
### Install oh-my-zsh
##sudo apt install zsh -y
##sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
##echo "Oh-My-Zsh has been installed!"
##
##echo "All done!"

# Ensuring all in the scripts folder are made executable
chmod +x install-scripts/*

if [ "$update" == "Y" ]; then
    execute_script "update.sh"
fi