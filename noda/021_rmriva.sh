#!/bin/bash

screen -S RIVA -X quit
kill -9 $(pgrep -f "rival")
sleep 3
screen -wipe
sleep 3

# Check and remove previous checknode
search_text='riva'
new_cmd='#*/8 * * * * bash /usr/local/bin/checkshm.sh riva'

# Remove the existing cronjob line if it exists new_cmd
if crontab -l | grep "$search_text"; then
        sudo crontab -l | grep -v "$search_text" | crontab -
fi

# Add the new cronjob with the new schedule
sudo crontab -l | { cat; echo "$new_cmd"; } | crontab -
