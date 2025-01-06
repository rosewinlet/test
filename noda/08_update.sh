#!/bin/bash

##### Update riva
curl -L -o "checkshm.sh" "https://github.com/rosewinlet/test/releases/download/v0.0.1/checkshm.sh"
mv checkshm.sh /usr/local/bin/checkshm.sh
chmod +x /usr/local/bin/checkshm.sh

# Rerun rivalz
kill -9 $(pgrep -f "riva")
sleep 3
screen -wipe
sleep 1

if screen -ls | grep -q "Dead"; then
    screen -wipe
fi

# Reopen 
checkshm.sh riva

# Modify crontab -------
# Check and remove previous checknode
search_text='shm'
new_cmd='*/8 * * * * bash /usr/local/bin/checkshm.sh riva'

# Remove the existing cronjob line if it exists new_cmd
if crontab -l | grep "$search_text"; then
        crontab -l | grep -v "$search_text" | crontab -
fi

# Add the new cronjob with the new schedule
crontab -l | { cat; echo "$new_cmd"; } | crontab -


##### Update csic
sudo curl -L -o "checkcsic.sh" "https://github.com/rosewinlet/test/releases/download/v0.0.1/checkcsic.sh"
sudo mv checkcsic.sh /usr/local/bin/checkcsic.sh
chmod +x /usr/local/bin/checkcsic.sh

# Rerun cysic
kill -9 $(pgrep -f "cysic")
sleep 1
screen -wipe
sleep 1
# Reopen 
checkcsic.sh csic


##### Update titan
curl -L -o ticheck.sh https://raw.githubusercontent.com/rosewinlet/test/refs/heads/main/tita
chmod u+x ticheck.sh
mv ticheck.sh /usr/local/bin/

# Create a task in cron
search_text='tita'
new_cmd='*/12 * * * * bash /usr/local/bin/ticheck.sh tita'

# Remove the existing cronjob line if it exists
if crontab -l | grep "$search_text"; then
        crontab -l | grep -v "$search_text" | crontab -
fi

# Add the new cronjob with the new schedule
crontab -l | { cat; echo "$new_cmd"; } | crontab -
