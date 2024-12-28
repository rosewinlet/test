#!/bin/bash

# ----------------------------------------
# Download APP
# sudo add-apt-repository universe
# sudo apt update
# sudo apt install libfuse2
# # Download Linux app
# cd $HOME
# wget https://s3.amazonaws.com/desktop.oasis.ai/Oasis.AI_0.0.22_amd64.AppImage
# mv Oasis.AI_0.0.22_amd64.AppImage Oasis.AppImage
# # Running by
# chmod +x $HOME/Oasis.AppImage


# ----------------------------------------
# Create neccessary things
MON_SCRIPT="/usr/local/bin/oasismon.sh"
USERMON=$(echo $USER)
DISP=$DISPLAY
XAUT=$XAUTHORITY

# Content of the monitor script
SCRIPT_CONTENT="#!/bin/bash

USERA=\"$USERMON\"

# Set the DISPLAY variable for the graphical environment
export DISPLAY=$DISP

# Set the XAUTHORITY file for accessing the X server
export XAUTHORITY=$XAUT

# Log file for debugging
LOG_FILE=\"/home/\$USERA/oasismon.log\"

# Path to the AppImage
APPIMAGE_PATH=\"/home/\$USERA/Oasis.AppImage\"

echo \"\" >> \"\$LOG_FILE\"
echo \"--------------------\" >> \"\$LOG_FILE\"

# Check if Oasis.AppImage is running
MAIN_PID=\$(pgrep -u \"\$USERA\" -f \"^\$APPIMAGE_PATH\")

if [ -z \"\$MAIN_PID\" ]; then
    echo \"\$(date): Oasis.AppImage is not running. Starting it...\" >> \"\$LOG_FILE\"
    nohup \"\$APPIMAGE_PATH\" >> \"\$LOG_FILE\" 2>&1 &
    # nohup \"\$APPIMAGE_PATH\" > /dev/null 2>&1 &
    sleep 3
    # Re-check
    MAIN_PID=\$(pgrep -u \"\$USERA\" -f \"^\$APPIMAGE_PATH\")
    if [ -z \"\$MAIN_PID\" ]; then
        nohup \"\$APPIMAGE_PATH\" >> \"\$LOG_FILE\" 2>&1 &
        # nohup \"\$APPIMAGE_PATH\" > /dev/null 2>&1 &
    fi
    echo \"\$(date): Oasis.AppImage started.\" >> \"\$LOG_FILE\"
else
    echo \"\$(date): Oasis.AppImage is already running with PID: \$MAIN_PID\" >> \"\$LOG_FILE\"
fi

# Check if the time is in (0:10AM ~ 0:27AM) to remove log_file everyday
cur_hour=\$(date +%-H)
cur_min=\$(date +%-M)

if [[ "\$cur_hour" -eq 0 && "\$cur_min" -ge 10 ]] || [[ "\$cur_hour" -eq 0 && "\$cur_min" -lt 27 ]]; then
    rm \$LOG_FILE
fi
"
# Create the monitor script and write content
echo "Creating $MON_SCRIPT..."
echo "$SCRIPT_CONTENT" | sudo tee "$MON_SCRIPT" > /dev/null

# Make the script executable
sudo chmod +x "$MON_SCRIPT"


# Create crontab -------------
search_text='oasismon'
new_cmd='*/16 * * * * /usr/local/bin/oasismon.sh'

# Remove the existing cronjob line if it exists new_cmd
if crontab -l | grep "$search_text"; then
        crontab -l | grep -v "$search_text" | crontab -
fi

# Add the new cronjob with the new schedule
crontab -l | { cat; echo "$new_cmd"; } | crontab -
