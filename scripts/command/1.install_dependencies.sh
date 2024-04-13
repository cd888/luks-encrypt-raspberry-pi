#!/bin/sh

# update OS files
sudo apt update && sudo apt upgrade -y

install_command="sudo apt install"

# install dependencies
$install_command busybox cryptsetup initramfs-tools cryptsetup-initramfs -y
$install_command expect --no-install-recommends -y

#sudo rpi-update
echo "Done. Reboot needed"
