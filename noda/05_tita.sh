#!/bin/bash

SC_SESSION="tita"
INIT_CMD="tted daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0"
RUN_CMD="tted daemon start"

# --------------
# Path to .bashrc or .profile - Extra code
BASHRC=~/.profile
# Remove the specific line if it exists
sudo sed -i '/export PATH="\$PATH:\/root\/.avail\/bin"/d' ~/.bashrc
# Add the new line if it doesn't already exist
grep -q 'export LD_LIBRARY_PATH=.*:/usr/local/bin/' "$BASHRC" || echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/bin/' >> "$BASHRC"

source $BASHRC
# --------------

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/bin/

# Stop old daemon
tted daemon stop
sleep 5
# Do it again
kill -9 $(pgrep -f "tted")

# RM old node
rm /usr/bin/ttca
rm /usr/bin/tted
rm /usr/bin/ttlo
rm /usr/bin/ttsche

if [ ! -d "/tmp/.tita" ]; then
    mkdir /tmp/.tita
fi
if [ ! -d "/media/.top" ]; then
    mkdir /media/.top
fi
cd /media/.top

# Back old node and rm data
mkdir /media/.top/herschel_bak
cp /root/.titanedge/config.toml /media/.top/herschel_bak/
cp /root/.titanedge/node_id /media/.top/herschel_bak/
cp /root/.titanedge/private.key /media/.top/herschel_bak/
cp /root/.titanedge/token /media/.top/herschel_bak/
cp /media/.top/nohash /media/.top/herschel_bak/
rm -rf /root/.titanedge
rm -rf /media/.top/tita

# Input node hash
read -p "Enter a node hash: " node_hash

# Backup to a file 
if [ -n "$node_hash" ]; then
    # Write the node_hash to a file
    echo "$node_hash" > nohash
else
    echo "Node hash is empty. Check input"
    exit
fi

# SSD CAPACITY WANNA RUN
read -p "Enter an amount of SSD to use (50GB, 100GB or ***GB (default 100GB)): " SSDCAPACITY
if [ -n "$SSDCAPACITY" ]; then
    # Write the node_hash to a file
    echo "You have choosed to run with SSD amount: " "$SSDCAPACITY" 
else
    echo "Not choose right number. Make default at 100GB"
    SSDCAPACITY="100GB"
    exit
fi

# Read the existing node hash
# read -r node_hash < /media/.top/nohash

# Print the variable
# echo "node hash: $node_hash"

# --------------------------------------------------------------------
# Get the latest version from github
rm tita.tar.gz
echo "Downloading from: https://github.com/Titannet-dao/titan-node/releases/download/v0.1.20/titan-edge_v0.1.20_246b9dd_linux-amd64.tar.gz"
curl -L -o tita.tar.gz "https://github.com/Titannet-dao/titan-node/releases/download/v0.1.20/titan-edge_v0.1.20_246b9dd_linux-amd64.tar.gz"

# Extract the file and process data
tar xvf tita.tar.gz
if ls *titan*linux*amd64* 1> /dev/null 2>&1; then
    rm -rf tita
    mv *titan*linux*amd64* ./tita
fi   
# ----------------------------

# Move to bin folder
mv /media/.top/tita/titan-edge /usr/bin/tted
mv /media/.top/tita/libgoworkerd.so /usr/local/bin/

# Run the command
# Start with screen -S to init
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/bin/
screen -dmS "$SC_SESSION" bash -c "$INIT_CMD"

# Start by background call
# nohup tted daemon start --init --url https://cassini-locator.titannet.io:5000/rpc/v0  > /tmp/.tita/edge.log 2>&1 &
# tted_pid=$!  # Get the PID of the last background process
# wait $tted_pid
# kill -9 $(pgrep -f "tted")
sleep 6

# Bind the node with account hash
echo "Node_hash: $node_hash"
tted bind --hash=$node_hash https://api-test1.container1.titannet.io/api/v2/device/binding

sleep 5
echo "Show info"
echo ""
tted show binding-info https://api-test1.container1.titannet.io/api/v2/device
echo ""

# -----------------------------------------------------------
# Re-configure crontab
search_text='ticheck.sh'
new_cmd='*/10 * * * * bash /usr/local/bin/ticheck.sh tita'

# Remove the existing cronjob line if it exists new_cmd
if crontab -l | grep "$search_text"; then
        crontab -l | grep -v "$search_text" | crontab -
fi

# Add the new cronjob with the new schedule
crontab -l | { cat; echo "$new_cmd"; } | crontab -

# ------- Create ticheck.sh in /usr/local/bin/ticheck.sh ---
# Update checker
curl -L -o ticheck.sh https://raw.githubusercontent.com/rosewinlet/test/refs/heads/main/tita

chmod u+x ticheck.sh
mv ticheck.sh /usr/local/bin/

#-------------------------
# Change disk space
tted config set --storage-size "$SSDCAPACITY"
# Restart node
tted daemon stop
sleep 2
screen -dmS "$SC_SESSION" bash -c "$RUN_CMD"
sleep 3
#-------------------------

# rm ~/tita_install.sh
history -c 

echo ""
echo "Done setup!"
echo ""
