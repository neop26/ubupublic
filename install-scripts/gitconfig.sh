#!/bin/bash


read -p "Enter the Email Address for Git config (e.g., something@somethingcom): " email
read -p "Enter the User for Git config (e.g., someone): " user


# Backup current .gitconfig
sudo cp ~/.gitconfig ~/.gitconfig.backup
sudo rm -r ~/.gitconfig

# Generate new .gitconfig

cat << EOF | sudo tee ~/.gitconfig
[user]
    email = $email
    name = $user
[credential]
    helper = store
EOF