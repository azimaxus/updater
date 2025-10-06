#!/bin/bash
# Script to update ACME.sh to the latest version

echo "Updating ACME.sh to latest version..."

# Backup current version
if [ -f "acme.sh" ]; then
    cp acme.sh acme.sh.backup.$(date +%Y%m%d_%H%M%S)
    echo "Current version backed up"
fi

# Download latest version
echo "Downloading latest ACME.sh..."
curl -s https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh -o acme.sh.new

if [ $? -eq 0 ]; then
    # Make executable
    chmod +x acme.sh.new
    
    # Replace old version
    mv acme.sh.new acme.sh
    
    echo "ACME.sh updated successfully!"
    echo "New version info:"
    ./acme.sh --version
else
    echo "Failed to download latest ACME.sh"
    exit 1
fi
