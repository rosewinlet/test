#!/bin/bash

cd ~

# Install jq
echo "Installing jq..."
sudo apt update
sudo apt install -y jq
echo "jq installed successfully."
sudo apt install htop -y
sudo apt install screen -y
sudo apt install curl -y
sudo apt install net-tools

# Remote desktop relating code

# uninstall desktop
sudo apt-get purge chrome-remote-desktop -y
sudo apt-get purge google-chrome-stable -y 
sudo apt-get remove brave-browser brave-keyring -y
sudo rm /etc/apt/sources.list.d/brave-browser-*.list
sudo apt-get purge ubuntu-desktop -y 
sudo apt-get purge ubuntu-desktop-minimal -y
sudo apt-get autoremove -y 


# Reinstall dekstop
# Script to install ubuntu desktop & chrome
# Download & install remote desktop
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo apt-get install --assume-yes ./chrome-remote-desktop_current_amd64.deb

# Download and install chrome browser:
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install --assume-yes ./google-chrome-stable_current_amd64.deb

# Remove stuffs
rm *deb

sudo apt-get install slim -y
sudo apt-get install ubuntu-desktop -y
# sudo apt-get install ubuntu-desktop-minimal -y
sudo systemctl enable slim
sudo systemctl start slim 

sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
