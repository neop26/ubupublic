#!/bin/bash
# Test script for menu functionality

# Source configuration
source "$(dirname "$(readlink -f "$0")")/config.sh"

# Simple function to display a menu and get selection
show_menu() {
    echo "Please select an option:"
    echo "1) Option One"
    echo "2) Option Two"
    echo "3) Option Three"
    echo "4) Exit"
    
    read -p "Enter choice [1-4]: " choice
    echo "You selected: $choice"
}

# Main function
main() {
    echo "Testing menu functionality"
    echo "-------------------------"
    show_menu
    echo "Menu test complete"
}

# Run the main function
main
