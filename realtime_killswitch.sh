#!/bin/bash

# --- CONFIGURATION ---
LIMIT_MB=5
INTERFACE="en0" # en0 is standard Mac Wi-Fi
LIMIT_BYTES=$((LIMIT_MB * 1024 * 1024))

echo "Fetching starting data..."

# 1. THE BASELINE: The script memorizes exactly how much data you've used today BEFORE the loop starts.
START_BYTES=$(vnstat -i $INTERFACE --json d 2>/dev/null | jq '.interfaces[0].traffic.day[0].rx + .interfaces[0].traffic.day[0].tx')

echo "Session monitor active. Starting fresh from 0 MB. Limit: $LIMIT_MB MB."

while true; do
    # 2. THE CURRENT TOTAL: Fetch the new total every second
    CURRENT_BYTES=$(vnstat -i $INTERFACE --json d 2>/dev/null | jq '.interfaces[0].traffic.day[0].rx + .interfaces[0].traffic.day[0].tx')

    if [ -n "$CURRENT_BYTES" ] && [ "$CURRENT_BYTES" != "null" ]; then
        
        # 3. THE MATH: Subtract the baseline from the current total to get "Session" data
        SESSION_BYTES=$((CURRENT_BYTES - START_BYTES))
        
        # 4. THE TRIGGER: Check if the NEW session data is over the limit
        if [ "$SESSION_BYTES" -ge "$LIMIT_BYTES" ]; then
            echo "CRITICAL: Session limit of $LIMIT_MB MB reached! Killing all connections NOW."
            
            # Turn off the Wi-Fi Antenna
            networksetup -setairportpower $INTERFACE off
            
            echo "Internet severed."
            exit 0
        fi
    fi
    
    sleep 1
done