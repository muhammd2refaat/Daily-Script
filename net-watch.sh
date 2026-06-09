#!/bin/bash

set -euo pipefail

CLEAN_COLUMNS="bytes_in,bytes_out,rcvsize,tc_class"

show_help() {
    cat <<'EOF'
Usage: net-watch.sh [app-name]

Without arguments, shows live network usage for the whole system.
With an app/process name, filters the view to that process.
EOF
}

APP_NAME="${1:-}"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

if [ -t 1 ]; then
    clear
fi

if [ -z "$APP_NAME" ]; then
    echo "=========================================================="
    echo " Monitoring WHOLE SYSTEM"
    echo " Press Control + C to exit"
    echo "=========================================================="
    echo ""
    exec nettop -J "$CLEAN_COLUMNS"
fi

echo "=========================================================="
echo " Monitoring APP/PROCESS: [$APP_NAME]"
echo " Press Control + C to exit"
echo "=========================================================="
echo ""

exec nettop -p "$APP_NAME" -J "$CLEAN_COLUMNS"
