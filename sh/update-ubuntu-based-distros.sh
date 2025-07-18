#!/bin/bash

# Full system update script for Ubuntu/Linux Mint

echo
echo "Updating package list..."
sudo apt update
echo

echo "Fixing broken installations and pending configurations..."
sudo dpkg --configure -a
sudo apt --fix-broken install -y
echo

echo "Upgrading installed packages..."
sudo apt upgrade -y
echo

echo "Applying full upgrade..."
sudo apt full-upgrade -y
echo

echo "Applying distribution upgrade (optional compatibility changes)..."
sudo apt dist-upgrade -y
echo

echo "Installing recommended drivers (if available)..."
sudo ubuntu-drivers autoinstall
echo

echo "Checking firmware devices..."
sudo fwupdmgr get-devices
echo

echo "Updating firmware..."
sudo fwupdmgr update
echo

echo "Removing unnecessary packages..."
sudo apt autoremove --purge -y
echo

echo "Cleaning up partial package files..."
sudo apt autoclean
echo

echo "Cleaning up retrieved package files..."
sudo apt clean
echo

# Check if flatpak is installed
if command -v flatpak >/dev/null 2>&1; then
    echo "Updating Flatpak packages..."
    sudo flatpak update -y
    echo
fi

# Check if snap is installed
if command -v snap >/dev/null 2>&1; then
    echo "Refreshing Snap packages..."
    sudo snap refresh
    echo
fi

echo "System update completed."
echo

# Ask to reboot
read -p "Do you want to reboot the system now? (y/N): " answer
echo
case "$answer" in
    [yY][eE][sS]|[yY])
        echo "Rebooting..."
        sudo reboot
        ;;
    *)
        echo "Reboot skipped."
        ;;
esac
