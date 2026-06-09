#!/bin/bash

# --- CONFIGURATION ---
LIMIT_MB=500
INTERFACE="en0" # en0 is standard Mac Wi-Fi
LIMIT_BYTES=$((LIMIT_MB * 1024 * 1024))

echo "Real-time monitor active. Checking every 1 second..."

while true; do
    # Fetch today's usage from vnstat's real-time database
    USED_BYTES=$(vnstat -i $INTERFACE --json d 2>/dev/null | jq '.interfaces[0].traffic.day[0].rx + .interfaces[0].traffic.day[0].tx')

    # If we got a valid number back, check if it exceeds the limit
    if [ -n "$USED_BYTES" ] && [ "$USED_BYTES" != "null" ]; then
        if [ "$USED_BYTES" -ge "$LIMIT_BYTES" ]; then
            echo "CRITICAL: Data limit of $LIMIT_MB MB reached! Killing all connections NOW."
            
            # Turn off the Wi-Fi Antenna immediately
            networksetup -setairportpower $INTERFACE off
            
            # (Optional) I disabled this because sudo requires a password and can freeze background scripts.
            # sudo ifconfig $INTERFACE down
            
            echo "Internet severed."
            # Exit the script completely since the internet is dead
            exit 0
        fi
    fi
    
    # Wait exactly 1 second before checking again
    sleep 1
done
