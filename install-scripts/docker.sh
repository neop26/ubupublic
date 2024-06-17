# Installing Docker on the Server

sudo apt install docker.io && sudo apt install docker-compose
sudo systemctl enable docker\
sudo systemctl start docker
sudo usermod -aG docker $USER
exit