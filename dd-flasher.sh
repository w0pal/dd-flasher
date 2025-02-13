#!/bin/bash

# Function to handle SIGINT (Ctrl+C)
handle_sigint() {
  echo ""
  echo "Process interrupted. Exiting..."
  if [ -n "$dd_pid" ]; then
    kill "$dd_pid"
  fi
  exit 1
}

# Trap SIGINT (Ctrl+C)
trap handle_sigint SIGINT

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "! dd-flasher -- A simple script to flash ISO/IMG files to USB drives using dd command. !"
echo "! v1.0.0                                                                               !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "! Developed for fun and educational purposes only.                                     !"
echo "! If you want to develop this script further, feel free to fork and contribute.        !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "! Tested on Debian trixie/sid, hopefully it's work on macOS :D                          !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
sleep 2
clear

# Check for fzf installation
if ! command -v fzf &>/dev/null; then
  echo "fzf is required but not installed. Install it first."
  exit 1
fi

# History file
HISTORY_FILE="./flash_history"

# Function to display history
display_history() {
  if [ -f "$HISTORY_FILE" ]; then
    echo "Previous operations:"
    cat "$HISTORY_FILE"
    echo ""
  else
    echo "No history found."
    echo ""
  fi
}

# Display history
display_history

sleep 2

# Input ISO/IMG file
echo "Select ISO/IMG file:"
if command -v fzf &>/dev/null; then
  ISO_FILE=$(find ./disk_image -type f \( -iname "*.iso" -o -iname "*.img" \) 2>/dev/null | fzf --prompt="Select ISO/IMG file: " --height=40% --border)
else
  echo "[ERROR] No suitable command found for file selection (fzf)."
  exit 1
fi

# Validate file
if [ ! -f "$ISO_FILE" ]; then
  echo "[ERROR] File not found: $ISO_FILE"
  exit 1
fi

# Input target device
echo "Select target device:"
if command -v lsblk &>/dev/null; then
  target_dev=$(lsblk -dpno NAME -e7 | fzf --prompt="Select Target Device: " --height=40% --border)
elif command -v diskutil &>/dev/null; then
  target_dev=$(diskutil list | grep "/dev/" | fzf | awk '{print $1}')
  diskutil info "$target_dev"
else
  echo "[ERROR] No suitable command found to list drives."
  exit 1
fi

# Validate target device
if [ ! -b "$target_dev" ]; then
  echo "[ERROR] Selected target is not a valid block device: $target_dev"
  exit 1
fi
clear

# Confirm before flashing
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "You are about to flash:"
echo "File: $ISO_FILE"
echo "To: $target_dev"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
lsblk "$target_dev" # Show detailed info of the selected device
read -p "Are you sure you want to continue? (y/N) " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "Cancelled"
  exit 0
fi

# Execute dd
echo ""
echo "Starting flashing process..."
(sudo dd if="$ISO_FILE" of="$target_dev" bs=4M status=progress && sync) &
dd_pid=$!
wait "$dd_pid"

# if [ $? -eq 0 ]; then
#   # Save to history
#   echo "$(date): $ISO_FILE -> $target_dev" >>"$HISTORY_FILE"
#   echo ""
#   echo "Process completed! Drive is ready to use."
# else
#   echo "[ERROR] Flashing process failed."
# fi

# Tambahkan header jika file history belum ada
if [ ! -f "$HISTORY_FILE" ]; then
  printf "%-12s | %-8s | %-10s | %-50s\n" "Date" "Time" "Partition" "Image File" >"$HISTORY_FILE"
  echo "------------------------------------------------" >>"$HISTORY_FILE"
fi

# Format tanggal dan waktu
CURRENT_DATE=$(date "+%m/%d/%Y")  # Format: MM/DD/YYYY
CURRENT_TIME=$(date "+%-I:%M %p") # Format: H:MM AM/PM

# Simpan ke history dengan format yang rapi
printf "%-12s | %-8s | %-10s | %-50s\n" "$CURRENT_DATE" "$CURRENT_TIME" "$target_dev" "$ISO_FILE" >>"$HISTORY_FILE"
