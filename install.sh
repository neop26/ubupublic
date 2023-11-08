# Bash script to install applications for a fresh Ubuntu Install

# Update and Upgrade
sudo apt update && sudo apt upgrade -y

# Install Snap
sudo apt install snapd -y

# Install Snap Packages
sudo snap install spotify
sudo snap install vlc
sudo snap install gimp
sudo snap install chromium
sudo snap install brave
sudo snap install firefox
sudo snap install opera
sudo snap install tor
sudo snap install bitwarden

# Install Flatpak
sudo apt install flatpak -y
sudo apt install gnome-software-plugin-flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# Flathub install Vscode
sudo flatpak install flathub com.visualstudio.code -y
# Flathub install Microsoft Edge
sudo flatpak install flathub com.microsoft.Edge -y

# Install Grub Optimizer
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo apt install grub-customizer -y

# Install Gnome Tweaks
sudo apt install gnome-tweaks -y

# Install Gnome Extensions
sudo apt install gnome-shell-extensions -y

# Install Gparted
sudo apt install gparted -y

# Install Neofetch
sudo apt install neofetch -y

# Install Htop
sudo apt install htop -y

# Install zsh
sudo apt install zsh -y

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Thunar
sudo apt install thunar -y

# Install Thunar Plugins
sudo apt install thunar-archive-plugin -y

# Install Thunar Media Tags
sudo apt install thunar-media-tags-plugin -y

# Install Thunar Thumbnailers
sudo apt install ffmpegthumbnailer -y

# Install Thunar Custom Actions
sudo apt install thunar-custom-actions -y

# Install Thunar Send To
sudo apt install thunar-sendto-clamtk -y