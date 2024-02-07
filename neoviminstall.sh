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
# cd ~/.config/nvim
sudo nvim
