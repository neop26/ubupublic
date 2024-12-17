# Introduction

This repo deploys scripts that have been inspired from [JaKooLit](https://github.com/JaKooLit/Debian-Hyprland) scripts for deploying Hyprland on Debian and few other flavors.

I use the script here to deploy the following for an Ubuntu Server:
- Update and Upgrade the server
- Install some fonts
- oh-my-zsh
- pokemon theme for zsh
- net-tools
- neofetch with custom config

## Installation Steps
- Clone the repo
- cd ubupublic
- chmod +x ubuservertemplate.sh
- bash ./ubuservertemplate.sh
- follow the prompts

## Configs
- assets/.zshrs
  - This contains the config for zsh with oh-my-zsh 
- config.conf - inspired from [Jackson Novak](https://gitlab.com/Oglo12/neofetch-config/-/blob/main/config.conf?ref_type=heads)
  - Neofetch custom config

# Changelog

v1.1 - 18/12/24
- Made some minor tweaks and improvements
- Added Nvidia Driver installer to run GPU capability for Docker Containers

v1.0 - 06/05/24
Tested to be working on
- 23.10
- 24.04