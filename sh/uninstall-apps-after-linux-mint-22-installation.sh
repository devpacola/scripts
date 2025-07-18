#!/bin/bash

# Vefify if the user start this script with command `sudo`
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

set -e

echo "Starting removal of specified applications..."

# List of packages to remove (including wildcard patterns)
packages=(
  "firefox" "firefox-locale-en" "firefox-locale-en"
  "webapp-manager"
  "simple-scan"
  "drawing"
  "pix" "pix-data"
  "thunderbird" "thunderbird-locale-en" "thunderbird-locale-en-us"
  "transmission-gtk"
  "libreoffice*"
  "celluloid"
  "hypnotix"
  "rhythmbox*" "librhythmbox-core10"
  "thingy"
  "onboard" "onboard-common"
  "seahorse"
  "warpinator"
  "gnome-screenshot"
  "xed*"
  "sticky"
)

# Update package indexes before removal
echo "Updating package indexes..."
sudo apt-get update

# Remove the packages and their configuration files (purge)
echo "Purging packages and their configs..."
sudo apt-get purge -y "${packages[@]}"

# Remove orphaned dependencies that are no longer needed
echo "Removing orphaned dependencies..."
sudo apt-get autoremove -y

# Clean apt cache to free disk space
echo "Cleaning apt cache..."
sudo apt-get clean

# Remove user configuration and data files for the current user
echo "Removing user configuration files..."

# Home directory of the current user
USER_HOME="/home/$USER"

# List of common config and cache directories for these applications
user_config_dirs=(
  ".mozilla"
  ".firefox"
  ".webapp-manager"
  ".simple-scan"
  ".drawing"
  ".pix"
  ".thunderbird"
  ".transmission-gtk"
  ".libreoffice"
  ".local/share/libreoffice"
  ".celluloid"
  ".hypnotix"
  ".cache/hypnotix"
  ".cache/celluloid"
  ".cache/simple-scan"
  ".cache/pix"
  ".cache/drawing"
  ".cache/webapp-manager"
  ".cache/warpinator"
  ".cache/rhythmbox"
  ".local/share/rhythmbox"
  ".config/rhythmbox"
  ".config/thingy"
  ".onboard"
  ".config/onboard"
  ".seahorse"
  ".warpinator"
)

# Loop through and delete these directories/files if they exist
for dir in "${user_config_dirs[@]}"; do
  full_path="$USER_HOME/$dir"
  if [ -d "$full_path" ] || [ -f "$full_path" ]; then
    echo "Removing $full_path"
    rm -rf "$full_path"
  fi
done

echo "Removing leftover orphaned packages with deborphan (if installed)..."

# Optionally remove orphaned packages via deborphan if it is installed
if command -v deborphan &> /dev/null; then
  sudo apt-get purge -y $(deborphan) || true
else
  echo "Deborphan is not installed, skipping additional orphan removal."
fi

echo "Cleanup complete."
