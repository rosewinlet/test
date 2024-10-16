#!/bin/bash

# Install for RIVALZ node with docker and proxy

# Install nodejs

apt install net-tools -y

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node --version

# Fetch the latest version of rivalz-node-cli
version=$(curl -s https://be.rivalz.ai/api-v1/system/rnode-cli-version | jq -r '.data')

# # Set latest version if version retrieval fails
# if [ -z "$version" ]; then
#     version="latest"
#     echo "Could not fetch the version. Defaulting to latest."
# fi

sudo npm i -g rivalz-node-cli@$version

# See disk serial num
# sudo lshw -class disk


apt-get install screen -y
screen -S RIVA -dm bash -c "rivalz run"
