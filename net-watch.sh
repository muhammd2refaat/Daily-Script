#!/bin/bash

clear

# Define exactly which columns to show (Process name and Type are always shown by default)
CLEAN_COLUMNS="bytes_in,bytes_out,rcvsize,tc_class"

if [ -z "$1" ]; then
    echo "=========================================================="
    echo " Monitoring WHOLE SYSTEM"
    echo " Press Control + C to exit"
    echo "=========================================================="
    echo ""
    # Run nettop showing ONLY the specific columns
    nettop -J $CLEAN_COLUMNS
else
    PROCESS_NAME=$1
    echo "=========================================================="
    echo " Monitoring SPECIFIC Process: [$PROCESS_NAME]"
    echo " Press Control + C to exit"
    echo "=========================================================="
    echo ""
    # Filter by process and show ONLY the specific columns
    nettop -p "$PROCESS_NAME" -J $CLEAN_COLUMNS
fi