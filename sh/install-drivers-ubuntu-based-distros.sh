echo "Installing recommended drivers (if available)..."
sudo ubuntu-drivers autoinstall
echo

echo "Checking firmware devices..."
sudo fwupdmgr get-devices
echo

echo "Updating firmware..."
sudo fwupdmgr update
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
