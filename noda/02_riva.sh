#!/bin/bash

sudo apt install net-tools -y
sudo apt-get install screen -y

# -------------------- Download checking script and make it --------------------
sudo curl -L -o "checkshm.sh" "https://github.com/rosewinlet/test/releases/download/v0.0.1/checkshm.sh"

sudo mv checkshm.sh /usr/local/bin/checkshm.sh

sudo chmod +x /usr/local/bin/checkshm.sh

# Add to crontab 
# Check and remove previous checknode
search_text='shm'
new_cmd='*/15 * * * * bash /usr/local/bin/checkshm.sh riva'

# Remove the existing cronjob line if it exists new_cmd
if crontab -l | grep "$search_text"; then
        sudo crontab -l | grep -v "$search_text" | crontab -
fi

# Add the new cronjob with the new schedule
sudo crontab -l | { cat; echo "$new_cmd"; } | crontab -


# -------------------- INSTALLING --------------------
# Install nodejs
sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
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

# RUN RIVALZ
screen -S RIVA -dm bash -c "rivalz run"
screen -r RIVA
