#!/bin/bash

# Define the directory to store VRAM dumps
vram_dir="/tmp/vram_dumps"
mkdir -p "$vram_dir"

# Time threshold for unloading VRAM (12 hours in seconds)
TIME_THRESHOLD=43200 # 12 hours

# Function to save VRAM data to disk
save_vram_data() {
    pid=$1
    vram_file="$vram_dir/vram_${pid}.bin"
    echo "Saving VRAM data for process $pid to $vram_file..."
    
    # Use nvidia-smi to dump VRAM data (example, replace with actual method)
    nvidia-smi -i 0 --gpu-target-processes $pid --query-gpu=memory.used --format=csv,noheader,nounits > "$vram_file"
}

# Function to unload VRAM data
unload_vram_data() {
    pid=$1
    echo "Unloading VRAM data for process $pid..."
    
    # Example: Simulate VRAM unloading (Replace with actual unload process)
    kill -9 $pid # Unload by killing the process (simplified for this example)
}

# Function to check if the process should be unloaded
check_and_unload_vram() {
    # Get the list of processes using the GPU
    processes=$(nvidia-smi --query-compute-apps=pid,used_memory,last_used --format=csv,noheader,nounits)

    # Loop through each process
    while IFS=',' read -r pid vram_usage last_used; do
        # Check if VRAM usage > 0 and process hasn't been used in the last 12 hours
        last_used_timestamp=$(date -d "$last_used" +%s)
        current_timestamp=$(date +%s)
        idle_time=$((current_timestamp - last_used_timestamp))
        
        if [ "$vram_usage" -gt 0 ] && [ "$idle_time" -gt "$TIME_THRESHOLD" ]; then
            # Save and unload VRAM data
            save_vram_data $pid
            unload_vram_data $pid
        fi
    done <<< "$processes"
}

# Function to reload VRAM data when the process needs to be used again
reload_vram_data() {
    pid=$1
    vram_file="$vram_dir/vram_${pid}.bin"
    
    if [ -f "$vram_file" ]; then
        echo "Reloading VRAM data for process $pid from $vram_file..."
        # Example: Simulate loading VRAM data (Replace with actual load process)
        nvidia-smi -i 0 --gpu-target-processes $pid --load-vram "$vram_file"
    else
        echo "No VRAM data found for process $pid."
    fi
}

# Run the script periodically (every hour)
while true; do
    check_and_unload_vram
    sleep 3600  # Check every hour
done