curl -sSL https://get.docker.com/ | sh
apt install docker-compose -y
docker-compose up -d
chmod +x serve.sh
./serve.sh