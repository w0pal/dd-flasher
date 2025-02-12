#!/bin/bash

# Get the list of attached drives
echo "Available drives:"
lsblk -d -o NAME,SIZE,MODEL
echo ""

# Input ISO/IMG file
read -p "Path to ISO/IMG file: " iso_path

# Validate file
if [ ! -f "$iso_path" ]; then
  echo "[ERROR] File not found: $iso_path"
  exit 1
fi

# Input target device
read -p "Select target device (e.g., sdb): " target_dev
target="/dev/${target_dev}"

# Validate target device
if [ ! -b "$target" ]; then
  echo "[ERROR] Invalid or not found device: $target"
  exit 1
fi

# Final confirmation
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "You are about to flash:"
echo "File: $iso_path"
echo "To: $target"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
read -p "Are you sure you want to continue? (y/N) " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "Cancelled"
  exit 0
fi

# Execute dd
echo ""
echo "Starting flashing process..."
sudo dd if="$iso_path" of="$target" bs=4M status=progress && sync

echo ""
echo "Process completed! Drive is ready to use."

