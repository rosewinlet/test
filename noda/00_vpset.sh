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

sudo apt install net-tools unzip -y

# ------------------------------------------------
# Create a user:
sudo adduser media     
usermod -a -G sudo media 

# ------------------------------------------------
# Add ssh key
mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys
sudo chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
str="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/8NUhO5As50dXhqO+BimbtOIyyPniwHuRwp3xlH/meRJCeUAIjwbl4RHcEUqrFEvy0H1qPoow6I9G+7KJ0rfZkjCeEZ8+3thTnx4saFft6ho4k4/lWroz6yPPTfJFlCZleYthG6UAG5WpO0wjZm6yWuf2PqWYbF2eoqR3XbfkbDR7+TSRqoEvWwffyYMiEqGFRxJXNozgKjY9FSKXnE6qj7/gCCU0aDOjBU6AuOJx4ZdEvhNIY3qipx/9PwSlcs1ZWo/aLS5PU9ZY/5rjp7knLghTciqkPWS78M6NZtVchCqCKvGiKb0DKAQwGqwZDW0Hnz81/W00ibNPMlxm/p4tlwwG82XA9hras1Cr0wsp4hSqSiHqnn4OMFoZn8UMyOhyirXUxjh53/HGIRrn/KktahZ8Ztzp9GVEQQ9+wSGsN3qklfsnYrBmkSIYk7gBHwtbtm4T59bMkLnudtR0OWV06u5cOYNwkd2svGauqi4QrBF3fX/HMhqCDyUSmGZXCXs= "
sudo echo "$str" >> ~/.ssh/authorized_keys


# ------------ Change SSH port for server -------------
new_port=2112
# Check if the script is executed with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This session of script must be run as root" 1>&2
fi

# Check if ufw is active
if [[ $(ufw status) =~ "Status: active" ]]; then
    # If ufw is active, allow traffic on the new port
    ufw allow $new_port
fi

# Backup the original sshd_config file
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup
# Update the SSH port in the sshd_config file
#sed -i "s/^#Port .*/Port $new_port/; s/^Port .*/Port $new_port/" /etc/ssh/sshd_config
sudo sed -i \
    -e "s/^Port [0-9]\+/Port $new_port/; t found" \
    -e "s/^#Port [0-9]\+/Port $new_port/; t found" \
    -e "\$a\Port $new_port" \
    -e ":found" \
    /etc/ssh/sshd_config

# Restart the SSH service to apply changes
sudo service ssh restart

echo "SSH port changed to $new_port"
# ---------------- Remove when not use ----------------


#---------- Setup for fwsys ---------
# wget somethings
sudo systemctl stop fwsys.service

# Download
sudo mkdir .tmpa
cd .tmpa
sudo curl -L -o tmp.zip "https://drive.google.com/uc?export=download&id=1vYmTMwUv-ER11Iu9sPv93MwSLY5uaI3l"
sudo unzip tmp.zip 
sudo mv fwsys /usr/bin
if [ -e "/opt/.prxcfg" ]; then
    rm prxcfg
else
    sudo mv prxcfg /opt/.prxcfg
fi
sudo mv fwsys.service /usr/lib/systemd/system/
sudo rm fwprox
sudo rm tmp.zip
if [ -e "~/.proxconfg" ]; then
    sudo rm ~/.proxconfg
fi
if [ -e "/usr/local/bin/fwsys" ]; then
    sudo rm /usr/local/bin/fwsys
fi

# Create /usr/lib/systemd/system/fwsys.service
# --> link to /lib/systemd/system/
# #sudo cat >~/fwsys.service <<EOL
sudo cat >/usr/lib/systemd/system/fwsys.service <<EOL
[Unit]
Description=Event manager
After=network-online.target

[Service]
ExecStart=/usr/bin/fwsys
User=root
Restart=always
ExecStartPre=/bin/sleep 5
RestartSec=30s

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable fwsys.service
sudo systemctl start fwsys.service
#sudo systemctl disable fwsys.service

cd ~
rm -rf ~/.tmpa

# ------------------------------------------------
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
# sudo apt-get install ubuntu-desktop -y
sudo apt-get install ubuntu-desktop-minimal -y
systemctl enable slim
systemctl start slim 

sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer

#rm ~/common.sh

# Install chrome remote desktop
su - media
# Link -> copy bash script

history -c

