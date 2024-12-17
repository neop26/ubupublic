# Install GCC
sudo apt install gcc -y

# Download and install the CUDA keyring
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb

# Update package lists
sudo apt-get update

# Install CUDA toolkit
sudo apt-get -y install cuda-toolkit-12-6

# Install NVIDIA open drivers
sudo apt-get install -y nvidia-open

# Add NVIDIA container toolkit repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update package lists again
sudo apt-get update

# Install NVIDIA container toolkit
sudo apt-get install -y nvidia-container-toolkit

# Configure NVIDIA runtime for Docker
sudo nvidia-ctk runtime configure --runtime=docker

# Restart Docker service
sudo systemctl restart docker

echo "NVIDIA driver installed"