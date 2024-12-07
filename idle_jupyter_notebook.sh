#!/bin/bash

# Define the directory where Jupyter notebooks are stored (adjust as per your setup)
NOTEBOOK_DIR="/path/to/jupyter/notebooks"
INACTIVE_THRESHOLD=43200  # 12 hours in seconds
LOG_FILE="/path/to/logs/dormant_notebooks.log"

# Function to check for dormant notebooks
check_dormant_notebooks() {
    current_time=$(date +%s)

    # Find all notebook files (*.ipynb) and check their last access time
    find "$NOTEBOOK_DIR" -type f -name "*.ipynb" | while read -r notebook; do
        # Get the last access time of the notebook
        last_access_time=$(stat -c %X "$notebook")

        # Calculate how long it's been since the last access
        idle_time=$((current_time - last_access_time))

        # If the notebook hasn't been used in the specified threshold, consider it dormant
        if [ "$idle_time" -gt "$INACTIVE_THRESHOLD" ]; then
            echo "Dormant notebook detected: $notebook (Last accessed: $(date -d @$last_access_time))"
            echo "$(date) - Dormant notebook detected: $notebook (Last accessed: $(date -d @$last_access_time))" >> "$LOG_FILE"
        fi
    done
}

# Run the check periodically (every hour)
while true; do
    check_dormant_notebooks
    sleep 3600  # Check every hour
done