#!/bin/bash

# Các lệnh cần chạy
docker volume prune -f
rm -rf /root/.nubit-light-nubit-alphatestnet-1/data

# Change crontab
search_text2='ticheck.sh'
new_cmd2='*/3 * * * * bash /usr/local/bin/ticheck.sh tita'

# Remove the existing cronjob line if it exists new_cmd2
if crontab -l | grep "$search_text2"; then
        crontab -l | grep -v "$search_text2" | crontab -
fi

# Add the new cronjob with the new schedule
crontab -l | { cat; echo "$new_cmd2"; } | crontab -


curl -O https://raw.githubusercontent.com/rosewinlet/test/main/tita && mv tita ticheck.sh && chmod u+x ticheck.sh && mv ticheck.sh /usr/local/bin/ticheck.sh


# Close Nub
screen -X -S "nunu" stuff "^C"
screen -X -S "tita" stuff "^C"
kill $(pgrep -f "tted")
kill $(pgrep -f "nubit")

sleep 5
ticheck.sh tita

history -c
