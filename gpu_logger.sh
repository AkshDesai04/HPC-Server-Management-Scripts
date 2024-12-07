#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 --interval <seconds>"
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --interval)
            interval="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Check if interval is set and valid
if [ -z "$interval" ] || ! [[ "$interval" =~ ^[0-9]+$ ]]; then
    echo "Error: Please provide a valid interval in seconds."
    usage
fi

# Define the output CSV file
output_file="gpu_log.csv"

# Write the CSV header if the file doesn't exist
if [ ! -f "$output_file" ]; then
    echo "Timestamp,GPU,Fan Speed (%),Temperature (C),GPU Utilization (%),Memory Usage (MB),Memory Utilization (%),Power Usage (W),Performance State,Compute Mode,Pcie Link Speed,Pcie Link Width,Driver Version,CUDA Version" > "$output_file"
fi

# Function to log GPU data
log_gpu_data() {
    # Get the number of GPUs
    num_gpus=$(nvidia-smi -L | wc -l)
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    for ((gpu=0; gpu<num_gpus; gpu++)); do
        # Extract GPU details using nvidia-smi
        fan_speed=$(nvidia-smi --query-gpu=fan.speed --format=csv,noheader,nounits -i $gpu)
        temperature=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits -i $gpu)
        gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits -i $gpu)
        memory_usage=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits -i $gpu)
        memory_util=$(nvidia-smi --query-gpu=memory.utilization --format=csv,noheader,nounits -i $gpu)
        power_usage=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits -i $gpu)
        performance_state=$(nvidia-smi --query-gpu=performance_state --format=csv,noheader -i $gpu)
        compute_mode=$(nvidia-smi --query-gpu=compute_mode --format=csv,noheader -i $gpu)
        pcie_link_speed=$(nvidia-smi --query-gpu=pcie.link.gen --format=csv,noheader -i $gpu)
        pcie_link_width=$(nvidia-smi --query-gpu=pcie.link.width --format=csv,noheader -i $gpu)
        driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader -i $gpu)
        cuda_version=$(nvidia-smi --query-gpu=cuda_version --format=csv,noheader -i $gpu)

        # Log the collected information into the CSV file
        echo "$timestamp,GPU$gpu,$fan_speed,$temperature,$gpu_util,$memory_usage,$memory_util,$power_usage,$performance_state,$compute_mode,$pcie_link_speed,$pcie_link_width,$driver_version,$cuda_version" >> "$output_file"
    done
}

# Run the logging in an infinite loop with the specified interval
while true; do
    log_gpu_data
    sleep "$interval"
done