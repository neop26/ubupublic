# Update the System
sudo pacman -Syu --noconfirm

# Install Nano
sudo pacman -Sy nano --noconfirm

# Install OpenSSH
sudo pacman -Sy openssh --noconfirm
sudo systemctl start sshd
echo "Started SSH"
sudo systemctl enable sshd
echo "Enabled SSH"

# Install and enable dhcpcd
sudo pacman -Sy dhcpcd --noconfirm
sudo systemctl enable dhcpcd
sudo systemctl start dhcpcd

# Change the Hostname of the Arch Install
echo "Enter the new hostname (leave empty to keep default): "
read newhostname
if [ -n "$newhostname" ]; then
  echo $newhostname | sudo tee /etc/hostname
  echo "Hostname changed to $newhostname"
else
  echo "Hostname left as default"
fi

## Change the IP Address to Static
#echo "Enter the new IP Address: "
#read newip
#echo "Enter the new Subnet Mask: "
#read newsubnet
#echo "Enter the new Gateway: "
#read newgateway
#echo "Enter the new DNS Server: "
#read newdns
#echo "What is the name of the network interface? "
#read newinterface
#
## Backup the current dhcpcd.conf
#sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak
#
## Configure static IP
#echo "interface $newinterface" | sudo tee -a /etc/dhcpcd.conf
#echo "static ip_address=$newip/$newsubnet" | sudo tee -a /etc/dhcpcd.conf
#echo "static routers=$newgateway" | sudo tee -a /etc/dhcpcd.conf
#echo "static domain_name_servers=$newdns" | sudo tee -a /etc/dhcpcd.conf
#
## Restart dhcpcd service to apply changes
#sudo systemctl restart dhcpcd
#echo "dhcpcd service restarted"

# Install Fastfetch
sudo pacman -Sy fastfetch --noconfirm
# Copy the fastfetch config to the user's home directory from the assets folder in the workspace
cp assets/fastfetchconfig.jsonc /home/$USER/.config/fastfetch/config.conf

# Install Docker
sudo pacman -Sy docker --noconfirm

# Install Docker Compose
sudo pacman -Sy docker-compose --noconfirm

# Start Docker service
sudo systemctl start docker

# Enable Docker service to start on boot
sudo systemctl enable docker

# Add the current user to the docker group
sudo usermod -aG docker $USER

# Inform the user to log out and back in
echo "Please log out and log back in to apply the Docker group changes."