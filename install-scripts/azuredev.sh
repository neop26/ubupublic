#!/bin/bash


# Ability to deploy repository
sudo apt install --reinstall software-properties-common -y

## Deploying Terraform
sudo apt install -y gnupg software-properties-common curl -y
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
terraform -install-autocomplete
source ~/.bashrc
## Test by terraform tab (Twice) this should show auto complete text
echo "Terraform has been installed!"
# Installing Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
echo "Azure CLI has been installed!"
# Update and install Bicep
curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
chmod +x ./bicep
sudo mv ./bicep /usr/local/bin/bicep
bicep --help # Verify Deployment
echo "Bicep has been installed!"
# Deploying Nvim
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get update -y
sudo apt install build-essential -y
sudo apt-get install manpages-dev -y
sudo apt install cmake -y
sudo apt-get install ninja-build gettext libtool-bin cmake g++ pkg-config unzip curl -y
sudo apt-get install neovim -y
# Configuring LazyVim
sudo mkdir .config/nvim
sudo git clone https://github.com/LazyVim/starter ~/.config/nvim
echo "Nvim has been installed!"

# Installing Powershell
sudo apt install dirmngr lsb-release ca-certificates software-properties-common apt-transport-https curl -y
curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/powershell.gpg > /dev/null
echo "deb [arch=amd64,armhf,arm64 signed-by=/usr/share/keyrings/powershell.gpg] https://packages.microsoft.com/ubuntu/22.04/prod/ jammy main" | sudo tee /etc/apt/sources.list.d/powershell.list
sudo apt install powershell
echo "PowerShell Installed"

# Install Nodejs
sudo apt install nodejs -y
sudo apt install npm -y
echo "Nodejs has been installed!" 

# Install pip
sudo apt install python3-pip -y
echo "Pip has been installed!"

# Install Ansible
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible -y
echo "Ansible has been installed!"