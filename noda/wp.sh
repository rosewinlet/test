#!/bin/bash

# Stop other docker daemon to update docker
CONTAINER_ID=$(docker ps -a | grep shardeum | awk '{print $1}')
docker stop $CONTAINER_ID

# Farcaster setup
datapath="/root/hub-monorepo/apps/hubble"

echo "Update & install"
cd ~/
sudo apt-get install ca-certificates curl gnupg screen htop -y 
sudo install -m 0755 -d /etc/apt/keyrings

# Check if the docker.gpg file exists
if [ ! -f "/etc/apt/keyrings/docker.gpg" ]; then
    # If the file does not exist, download the GPG key and save it
    echo | sudo -S curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
fi

echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Update again"
sudo apt-get update -y

echo "Install docker"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose docker-compose-plugin -y

echo "Clone and setup environmental variables"
git clone https://github.com/farcasterxyz/hub-monorepo.git
cd hub-monorepo/apps/hubble

echo "SUB1>> Temp run to create directory"
docker compose run hubble yarn identity create 

chmod 777 -R .rocks/
chmod 777 -R .hub/

echo "SUB2>> Main compile"
docker compose run hubble yarn identity create


# Create .env
nano $datapath/.env

# Run the node
cd $datapath
pwd
history -c
# docker compose up statsd grafana -d
docker compose up hubble -d

# Send a done signal for later
touch ~/done_all


# Check and remove previous checknode
search_text='hubble'
new_cmd='*/10 * * * * bash /usr/local/bin/checknode.sh hubble'

# Remove the existing cronjob line if it exists
if crontab -l | grep "$search_text"; then
        crontab -l | grep -v "$search_text" | crontab -
fi

# Add the new cronjob with the new schedule
crontab -l | { cat; echo "$new_cmd"; } | crontab -

# nano /usr/local/bin/checknode.sh
# chmod u+x /usr/local/bin/checknode.sh
sudo curl -L -o "checknode.sh" "https://github.com/rosewinlet/test/releases/download/v0.0.1/check_new.sh"
sudo mv checknode.sh /usr/local/bin/checknode.sh
sudo chmod +x /usr/local/bin/checknode.sh
