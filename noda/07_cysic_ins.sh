#!/bin/bash

read -sp "Enter the metamask wallet (Run this exactly 1 time): " META_WAL
echo

curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh \
 && bash ~/setup_linux.sh $META_WAL

# Create cron -------------------------
sudo curl -L -o "checkcsic.sh" "https://github.com/rosewinlet/test/releases/download/v0.0.1/checkcsic.sh"
sudo mv checkcsic.sh /usr/local/bin/checkcsic.sh
chmod +x /usr/local/bin/checkcsic.sh

sudo systemctl enable cron
sudo systemctl start cron

# Add to crontab ---------------------
# Check and remove previous checknode
search_text='csic'
new_cmd='*/16 * * * * bash /usr/local/bin/checkcsic.sh csic'

# Remove the existing cronjob line if it exists new_cmd
if crontab -l | grep "$search_text"; then
        crontab -l | grep -v "$search_text" | crontab -
fi

# Add the new cronjob with the new schedule
crontab -l | { cat; echo "$new_cmd"; } | crontab -
# -------------------------------------

checkcsic.sh csic
sleep 10

# Backup key file:
mkdir -p /opt/cysicbak/
key_file=$(find ~/.cysic/keys/ -type f -name "*.key" -print -quit)
file_name=$(basename "$key_file" .key)

cd /opt/cysicbak/
if [[ -f "$file_name.key" ]]; then
  cp ~/.cysic/keys/$file_name.key  /opt/cysicbak/$file_name.key2
  cp /opt/cysicbak/$file_name.key2  /opt/cysicbak/$file_name.key2.bak
else 
  cp ~/.cysic/keys/$file_name.key  /opt/cysicbak/
  cp /opt/cysicbak/$file_name.key  /opt/cysicbak/$file_name.key.bak
fi
