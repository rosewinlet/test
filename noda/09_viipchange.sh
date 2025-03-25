#!/bin/bash

# Prompt user for the IP address
read -p "Enter the desired IP address (e.g., 210.182.84.70): " IPWANT

# Check if the input is a valid IP (basic validation)
if ! [[ "$IPWANT" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid IP address format. Please use the format xxx.xxx.xxx.xxx"
    exit 1
fi

# Define the Netplan configuration file
NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"

sudo rm $NETPLAN_FILE

# Write the configuration to the file with the user-provided IP
cat << EOF | sudo tee $NETPLAN_FILE > /dev/null
network:
    version: 2
    ethernets:
        enp2s0:
            dhcp4: true
        enp1s0:
            dhcp4: no
            addresses:
                - $IPWANT/24
            nameservers:
                addresses:
                    - 203.248.252.2
                    - 164.124.101.2
            routes:
                - to: default
                  via: 210.182.84.65
EOF

# Set the correct permissions
sudo chmod 600 $NETPLAN_FILE

# Run netplan try and automatically accept after a brief delay
echo "Applying the Netplan configuration..."
sudo netplan try &
NETPLAN_PID=$!

# Wait 2 seconds and simulate pressing Enter to accept
sleep 2
echo "Accepting changes..."
echo | sudo kill -SIGINT $NETPLAN_PID

# Check if the command succeeded
if [ $? -eq 0 ]; then
    echo "Netplan configuration applied successfully!"
else
    echo "Error: Something went wrong while applying the configuration."
    exit 1
fi

# Verify the IP (optional)
echo "Current IP configuration for enp1s0:"
ip addr show dev enp1s0
