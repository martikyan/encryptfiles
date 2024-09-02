#!/bin/bash

# Define the target directory for binaries
BIN_DIR="/usr/local/bin"

# Check if the bin directory exists
if [ ! -d "$BIN_DIR" ]; then
  echo "Directory $BIN_DIR does not exist. Please create it or choose a different directory."
  exit 1
fi

# Path to the encryptfiles.sh script
SCRIPT_PATH="./encryptfiles.sh"

# Create a symbolic link in the bin directory
ln -sf "$(realpath $SCRIPT_PATH)" "$BIN_DIR/encryptfiles"

echo "Symbolic link created: $BIN_DIR/encryptfiles -> $(realpath $SCRIPT_PATH)"