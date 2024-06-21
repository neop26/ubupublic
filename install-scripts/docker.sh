# Installing Docker on the Server

sudo apt install docker.io -y && sudo apt install docker-compose -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
exit