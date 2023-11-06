# Bash script to install applications for a fresh Ubuntu Install

# Update and Upgrade
sudo apt update && sudo apt upgrade -y

# Install Snap
sudo apt install snapd -y

# Install Snap Packages
sudo snap install spotify
#sudo snap install discord
sudo snap install slack --classic
#sudo snap install postman
#sudo snap install insomnia
sudo snap install vlc
sudo snap install gimp
#sudo snap install inkscape
#sudo snap install audacity
#sudo snap install obs-studio
#sudo snap install kdenlive
#sudo snap install libreoffice
#sudo snap install mailspring
#sudo snap install telegram-desktop
#sudo snap install zoom-client
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
sudo flatpak install flathub com.visualstudio.code
# Flathub install Microsoft Edge
sudo flatpak install flathub com.microsoft.Edge
