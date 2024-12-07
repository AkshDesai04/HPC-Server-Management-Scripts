#!/bin/bash

# Default threshold is 10 minutes (600 seconds) if not provided
THRESHOLD_MINUTES=${1:-10}
THRESHOLD_SECONDS=$((THRESHOLD_MINUTES * 60))

# Get the current time
current_time=$(date +%s)

# Function to check idle processes holding resources
check_idle_processes() {
    # List processes with their start time, PID, memory usage, and command
    ps -eo pid,etime,%mem,command --sort=etime | while read pid etime mem cmd; do
        # Skip the header line
        if [[ "$pid" == "PID" ]]; then
            continue
        fi
        
        # Convert elapsed time to seconds
        elapsed_time=$(echo "$etime" | awk -F'[-:]' '{if(NF==2){print $1*60 + $2}else if(NF==3){print $1*3600 + $2*60 + $3}else{print 0}}')
        
        # Check if the process is idle and holding resources
        if [ "$elapsed_time" -ge "$THRESHOLD_SECONDS" ]; then
            # Check if the process is consuming significant memory (e.g., > 1% of total memory)
            if [ "$(echo "$mem > 1" | bc)" -eq 1 ]; then
                echo "Process holding resources but idle:"
                echo "PID: $pid"
                echo "Elapsed Time: $etime"
                echo "Memory Usage: $mem%"
                echo "Command: $cmd"
                echo "-----------------------------"
            fi
        fi
    done
}

# Run the function
check_idle_processes