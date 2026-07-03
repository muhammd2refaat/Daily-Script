#!/bin/bash

# --- CONFIGURATION ---

# Define where to save the history file
LOG_FILE="$HOME/netwatch_history.txt"

# 1. Read the command-line argument OR set a default
if [ -n "$1" ]; then
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        LIMIT_MB=$1
    else
        echo "Error: The limit must be a number."
        echo "Usage: ./netwatch.sh [Megabytes]"
        exit 1
    fi
else
    LIMIT_MB=5 # Default to 5 MB
fi

INTERFACE="en0" # en0 is standard Mac Wi-Fi
LIMIT_BYTES=$((LIMIT_MB * 1024 * 1024))

echo "Connecting to Wi-Fi hardware..."

# Function to read live byte counts directly from the Wi-Fi card
get_live_bytes() {
    netstat -I "$INTERFACE" -b | awk '/<Link#/ {print $7 + $10}'
}

# 2. THE BASELINE: Memorize the hardware state right now
START_BYTES=$(get_live_bytes)

if [ -z "$START_BYTES" ]; then
    echo "Error: Could not read from $INTERFACE. Is Wi-Fi turned on?"
    exit 1
fi

echo "Session monitor active. Starting fresh from 0 MB. Limit: $LIMIT_MB MB."

# LOGGING: Record the start of the session
echo "[$(date '+%Y-%m-%d %H:%M:%S')] START: Session started with $LIMIT_MB MB limit." >> "$LOG_FILE"

while true; do
    # 3. THE CURRENT TOTAL: Fetch live hardware bytes every second
    CURRENT_BYTES=$(get_live_bytes)

    if [ -n "$CURRENT_BYTES" ]; then
        
        # 4. THE MATH
        SESSION_BYTES=$((CURRENT_BYTES - START_BYTES))
        
        # Print real-time usage to the screen so you can watch it climb
        CURRENT_MB=$(awk "BEGIN {printf \"%.2f\", $SESSION_BYTES / 1024 / 1024}")
        echo -ne "Live Usage: $CURRENT_MB MB / $LIMIT_MB MB\r"
        
        # 5. THE TRIGGER
        if [ "$SESSION_BYTES" -ge "$LIMIT_BYTES" ]; then
            echo -e "\nCRITICAL: Session limit of $LIMIT_MB MB reached!"
            
            # Turn off the Wi-Fi Antenna instantly
            networksetup -setairportpower "$INTERFACE" off
            
            # LOGGING: Record that the limit was hit and the internet was cut
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] TRIGGER: $LIMIT_MB MB limit reached. Wi-Fi disabled." >> "$LOG_FILE"
            
            echo "Internet severed."
            exit 0
        fi
    fi
    
    # Check every half-second to be even more aggressive
    sleep 0.5
done