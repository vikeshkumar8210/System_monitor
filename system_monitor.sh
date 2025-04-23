#!/bin/bash

LOG_FILE="system_monitor2.log"
CPU_THRESHOLD=75    # in percent
MEM_THRESHOLD=80    # in percent
DISK_THRESHOLD=85   # in percent

# Function to get CPU load
get_cpu_load() {
    top -bn1 | grep "Cpu(s)" | \
        awk '{print 100 - $8}' # Subtract idle from 100
}

# Function to get memory usage
get_mem_usage() {
    free | awk '/Mem:/ { printf("%.2f"), $3/$2 * 100.0 }'
}

# Function to get disk usage
get_disk_usage() {
    df / | awk 'NR==2 {print $5}' | sed 's/%//'
}

# Clear screen and run loop
while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    CPU_LOAD=$(get_cpu_load)
    MEM_USAGE=$(get_mem_usage)
    DISK_USAGE=$(get_disk_usage)

<<comment
    ALERT_MSG=""

    if (( $(echo "$CPU_LOAD > $CPU_THRESHOLD" | bc -l) )); then
        ALERT_MSG+="[ALERT] High CPU load: ${CPU_LOAD}%\n"
    fi

    if (( $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) )); then
        ALERT_MSG+="[ALERT] High Memory usage: ${MEM_USAGE}%\n"
    fi

    if (( $(echo "$DISK_USAGE > $DISK_THRESHOLD" | bc -l) )); then
        ALERT_MSG+="[ALERT] High Disk usage: ${DISK_USAGE}%\n"
    fi
comment

    # Display dashboard
    clear
    echo "=== System Monitor Dashboard ==="
    echo "Time: $TIMESTAMP"
    echo "CPU Load     : ${CPU_LOAD}%"
    echo "Memory Usage : ${MEM_USAGE}%"
    echo "Disk Usage   : ${DISK_USAGE}%"
    echo -e "$ALERT_MSG"

    # Log to file
    echo "$TIMESTAMP | CPU: ${CPU_LOAD}% | MEM: ${MEM_USAGE}% | DISK: ${DISK_USAGE}%" >> "$LOG_FILE"
    if [ -n "$ALERT_MSG" ]; then
        echo -e "$ALERT_MSG" >> "$LOG_FILE"
    fi

    sleep 1
done

