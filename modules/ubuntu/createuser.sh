# Moved from install-scripts: createuser.sh (ubuntu-specific)
#!/bin/bash

# Prompt for new user information
read -p "Enter the new username: " username
read -s -p "Enter the password: " password
echo

# Create the new user with the input information
sudo adduser --gecos "" $username

# Set the password for the new user
echo "$username:$password" | sudo chpasswd

# Add the new user to the sudo group
sudo usermod -aG sudo $username

# Disable the root account
sudo passwd -l root

echo "User $username created and added to the sudo group. Root account disabled."
# Moved from install-scripts: createuser.sh (ubuntu-specific)
