#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi

# Get the Ubuntu version
version=$(lsb_release -r | awk '{print $2}')

# Convert the version to a number for comparison
version_number=$(echo $version | sed 's/\.//')

# Set the minimum supported version
min_version_number=2204

# Compare the versions
if [ "$version_number" -lt "$min_version_number" ]; then
    echo -e "${RED}Current Ubuntu Version: "$version".${RESET}"
    echo "" && sleep 1
    echo -e "${RED}Required Ubuntu Version: 22.04.${RESET}"
    echo "" && sleep 1
    echo -e "${RED}Please use Ubuntu version 22.04 or higher.${RESET}"
    exit 1
fi  

# Do a backup and rm neccessary old node (if existed)
sudo systemctl stop story
sudo systemctl stop story-geth

# Backup priv & Remove old data
cp ~/.story/story/data/priv_validator_state.json ~/.story/priv_validator_state.json.backup
cp ~/.story/story/config/priv_validator_key.json ~/.story/priv_validator_key.json.backup
mkdir /opt/storybak
cp ~/.story/story/config/wallet.txt /opt/storybak
cp ~/.story/story/config/priv_validator_key.json /opt/storybak

# Remove old node
rm -rf ~/.story/geth
rm -rf ~/.story/story

# Start installing the node
NODE="story"
DAEMON_HOME="$HOME/.story/story"
DAEMON_NAME="story"
if [ -d "$DAEMON_HOME" ]; then
    new_folder_name="${DAEMON_HOME}_$(date +"%Y%m%d_%H%M%S")"
    mv "$DAEMON_HOME" "$new_folder_name"
fi
#CHAIN_ID="odyssey"
#echo 'export CHAIN_ID='\"${CHAIN_ID}\" >> $HOME/.bash_profile

if [ ! $VALIDATOR ]; then
    read -p "Enter validator name: " VALIDATOR
    echo 'export VALIDATOR='\"${VALIDATOR}\" >> $HOME/.bash_profile
fi
echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
source $HOME/.bash_profile
sleep 1
cd $HOME
sudo apt update
sudo apt install make unzip clang pkg-config lz4 libssl-dev build-essential git jq ncdu bsdmainutils htop -y < "/dev/null"

# echo -e '\n\e[42mInstall Go\e[0m\n' && sleep 1
# cd $HOME
# VERSION=1.23.0
# wget -O go.tar.gz https://go.dev/dl/go$VERSION.linux-amd64.tar.gz
# sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz && rm go.tar.gz
# echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
# echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
# echo 'export GO111MODULE=on' >> $HOME/.bash_profile
# echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile
# go version

echo -e '\n\e[42mInstall software\e[0m\n' && sleep 1

# ---------- Download STORY ------------
#sleep 1
cd $HOME
rm -rf story
#git clone https://github.com/piplabs/story.git
#cd story
#git checkout v0.9.11
#make build

# Or Tracking github here: https://github.com/piplabs/story/releases

REPO="piplabs/story"

# Fetch the latest release data from GitHub API
echo "Fetching the latest release data..."
RELEASE_DATA=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")

# Extract the tag name and convert it to version (e.g., 0.1.19 -> v0.1.19)
TAG_NAME=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
VERSION="$TAG_NAME"

# Extract asset names and URLs with the specific pattern
echo "Parsing release data..."
ASSET_NAME=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | contains("story") and contains("linux") and contains("amd64")) | .name') 
ASSET_NAME=$(echo $ASSET_NAME | awk '{print $1}')
ASSET_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | contains("story") and contains("linux") and contains("amd64")) | .browser_download_url')
ASSET_URL=$(echo $ASSET_URL | awk '{print $1}')


# Start download
wget -O story-linux-amd64 $ASSET_URL
#tar xvf story-linux-amd64.tar.gz
# mv story-linux-amd64*/story .
sudo chmod +x story-linux-amd64*
sudo mv story-linux-amd64* /usr/local/bin/story
story version
#rm story-linux-amd64.tar.gz
rm -rf story-linux-amd64*

# ---------- Ended Download STORY ------------


# ---------- Download GETH ------------
cd $HOME
rm -rf story-geth
#git clone https://github.com/piplabs/story-geth.git
#cd story-geth
#git checkout v0.9.2
#make geth
# Tracking github here: https://github.com/piplabs/story-geth/releases


# Detect GETH
REPO="piplabs/story-geth"

# Fetch the latest release data from GitHub API
echo "Fetching the latest release data..."
RELEASE_DATA=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")

# Extract the tag name and convert it to version (e.g., 0.1.19 -> v0.1.19)
TAG_NAME=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
VERSION="$TAG_NAME"

# Extract asset names and URLs with the specific pattern
echo "Parsing release data..."
ASSET_NAME=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | contains("geth") and contains("linux") and contains("amd64")) | .name') 
ASSET_NAME=$(echo $ASSET_NAME | awk '{print $1}')
ASSET_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | contains("geth") and contains("linux") and contains("amd64")) | .browser_download_url')
ASSET_URL=$(echo $ASSET_URL | awk '{print $1}')

# Download
#wget -O geth https://github.com/piplabs/story-geth/releases/download/v0.9.4/geth-linux-amd64
wget -O story-geth $ASSET_URL
sudo chmod +x story-geth
sudo mv story-geth /usr/local/bin/story-geth
# ---------- Ended Download GETH ------------

# Init chain
# $DAEMON_NAME init --network odyssey  --moniker "${VALIDATOR}"
story init --network odyssey --moniker "${VALIDATOR}"

sleep 1
story validator export --export-evm-key --evm-key-path $HOME/.story/.env
story validator export --export-evm-key >>$HOME/.story/story/config/wallet.txt
cat $HOME/.story/.env >>$HOME/.story/story/config/wallet.txt


sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF  
[Unit]
Description=Story execution daemon
After=network-online.target

[Service]
User=$USER
#WorkingDirectory=$HOME/.story/geth
ExecStart=/usr/local/bin/story-geth --odyssey --syncmode full
Restart=always
RestartSec=3
LimitNOFILE=infinity
LimitNPROC=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/$NODE.service > /dev/null <<EOF  
[Unit]
Description=Story consensus daemon
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/.story/story
ExecStart=/usr/local/bin/story run
Restart=always
RestartSec=3
LimitNOFILE=infinity
LimitNPROC=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

# Add peers
PEERS=$(curl -sS https://story-cosmos-rpc.spidernode.net/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
echo $PEERS
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.story/story/config/config.toml

# Restore the old validator if existed
sudo cp /opt/storybak/priv_validator_key.json ~/.story/story/config/priv_validator_key.json

#echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable $NODE
sudo systemctl restart $NODE
sudo systemctl enable story-geth
sudo systemctl restart story-geth
sleep 5


cho -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service $NODE status | grep active` =~ "running" ]]; then
  echo -e "Your $NODE node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice story status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your $NODE node \e[31mwas not installed correctly\e[39m, please reinstall."
fi

# Create validator
# story validator create --stake 1000000000000000000 --private-key "your_private_key"

# Stake here
# Get info: curl -s localhost:26657/status | jq -r '.result.validator_info' => Get this value: VALIDATOR_PUB_KEY_IN_BASE64 (get in value)
# story validator stake \
#    --validator-pubkey "VALIDATOR_PUB_KEY_IN_BASE64" \
#    --stake 1000000000000000000 \
#    --private-key xxxxxxxxxxxxxx
