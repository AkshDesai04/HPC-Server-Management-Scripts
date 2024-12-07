#!/bin/bash

# Define the directory for the package cache
CACHE_DIR="/path/to/package_cache"

# Make sure the cache directory exists
mkdir -p "$CACHE_DIR"

# Define the pip cache path
PIP_CACHE_DIR="$CACHE_DIR/pip_cache"

# Create a local pip cache directory if it doesn't exist
mkdir -p "$PIP_CACHE_DIR"

# Function to install a package with pip and cache it
install_and_cache_package() {
    package=$1

    # Check if the package is already in the cache
    if [ ! -f "$PIP_CACHE_DIR/$package.tar.gz" ]; then
        echo "Package $package is not cached. Installing and caching..."
        
        # Install the package using pip and cache it locally
        pip install --cache-dir="$PIP_CACHE_DIR" "$package"
        
        # If installation was successful, move the package into the local cache directory
        if [ $? -eq 0 ]; then
            echo "Caching package $package to $PIP_CACHE_DIR"
            cp -r "$(pip show -f "$package" | grep Location | cut -d ' ' -f 2)/$package" "$PIP_CACHE_DIR/"
        else
            echo "Failed to install package $package."
        fi
    else
        echo "Package $package is already cached. Installing from cache..."
        
        # Install the package from the local cache
        pip install --find-links="$PIP_CACHE_DIR" --no-index "$package"
    fi
}

# Function to monitor pip installations from notebooks
monitor_notebooks() {
    while true; do
        # Monitor for running Jupyter notebooks that might invoke pip install
        # Here we assume that pip commands are logged to a specific log file
        # Replace this with a better mechanism to track pip calls as needed
        tail -n 0 -F /path/to/jupyter/notebooks/logs | grep -i "pip install" | while read -r line; do
            # Extract the package name from the pip install command
            package=$(echo "$line" | awk -F 'install ' '{print $2}')
            install_and_cache_package "$package"
        done
        sleep 1
    done
}

# Start monitoring pip installs
monitor_notebooks