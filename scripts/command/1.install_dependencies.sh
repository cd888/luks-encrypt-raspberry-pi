#!/bin/bash

# update OS files
sudo apt update && sudo apt upgrade -y

install_command="sudo apt install"

# install dependencies
$install_command busybox cryptsetup initramfs-tools -y
$install_command expect --no-install-recommends -y

#sudo rpi-update
echo "Done. Reboot needed"

printf "Do you want to reboot now? \n Y or N"
read decision

if $decision '==' Y; then
    sudo reboot now
fi