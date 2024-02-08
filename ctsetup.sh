# Bash script to install applications for a fresh Ubuntu CT

#!/bin/bash

# Update and Upgrade
sudo apt update && sudo apt upgrade -y

# Add Net Tools
sudo apt install net-tools -y

# Install Neofetch
sudo apt install neofetch -y

# Install Htop
sudo apt install htop -y

# Ability to deploy repository
sudo apt install --reinstall software-properties-common -y

## Deploying Terraform onto Ubuntu Container
# Add the HashiCorp GPG key.
sudo apt install -y gnupg software-properties-common curl -y
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
terraform -install-autocomplete
source ~/.bashrc
## Test by terraform tab (Twice) this should show auto complete text
echo "Terraform has been installed!"
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

echo "All done!"
