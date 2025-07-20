#!/bin/bash

# Vefify if the user start this script with command `sudo`
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting removal of specified applications..."

# List of packages to remove (including wildcard patterns)
# IMPORTANT: Review this list carefully! Removing some of these,
# like 'xed', 'thingy' (Xreader), or 'sticky' (XApp Stickynotes),
# might remove core desktop utilities.
packages=(
  "firefox" "firefox-locale-en" # "firefox-locale-en" was duplicated, removed one instance
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
  "thingy" # Xreader (document viewer)
  "onboard" "onboard-common"
  "seahorse"
  "warpinator"
  "gnome-screenshot"
  "xed*" # Xed (default text editor)
  "sticky" # XApp Stickynotes
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

## Removing User Configuration Files
echo "Removing user configuration files..."

# Get the original user who ran sudo
# This ensures we're cleaning the *correct* user's home directory, not root's.
if [ -n "$SUDO_USER" ]; then
    ORIGINAL_USER="$SUDO_USER"
else
    echo "Warning: SUDO_USER not set. Attempting to determine user via logname/whoami."
    ORIGINAL_USER=$(logname 2>/dev/null || whoami) # Fallback, less reliable
    if [ "$ORIGINAL_USER" = "root" ]; then
        echo "Error: Could not determine original user. User configuration removal skipped."
        exit 1
    fi
fi

USER_HOME="/home/$ORIGINAL_USER"

# List of common config and cache directories for these applications
# This will delete ALL user data associated with these applications (e.g., Firefox profiles, Thunderbird emails)
user_config_dirs=(
  ".mozilla"
  ".firefox" # Often a symlink to .mozilla, good to have it here
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
  ".config/thingy" # Added based on package list (Xreader config)
  ".config/sticky" # Added based on package list (XApp Stickynotes config)
  ".onboard"
  ".config/onboard"
  ".seahorse"
  ".warpinator"
  # Add other potential user config directories if you identify them
)

# Loop through and delete these directories/files if they exist
for dir in "${user_config_dirs[@]}"; do
  full_path="$USER_HOME/$dir"
  if [ -d "$full_path" ] || [ -f "$full_path" ]; then
    echo "Removing $full_path (as $ORIGINAL_USER)"
    # Use sudo -u to run rm as the original user, preserving permissions in the home directory
    sudo -u "$ORIGINAL_USER" rm -rf "$full_path"
  else
    echo "Skipping $full_path (does not exist)"
  fi
done

## Final System Cleanup
echo "Removing leftover orphaned packages with deborphan (if installed)..."

# Optionally remove orphaned packages via deborphan if it is installed
# '|| true' prevents the script from exiting if deborphan finds nothing or purge fails.
if command -v deborphan &> /dev/null; then
  sudo apt-get purge -y $(deborphan) || true
else
  echo "Deborphan is not installed, skipping additional orphan removal."
fi

echo "Cleanup complete."

# Link to execute in terminal:
# curl -sL https://raw.githubusercontent.com/devpacola/scripts/main/sh/uninstall-apps-after-linux-mint-22-installation.sh | sudo bash
