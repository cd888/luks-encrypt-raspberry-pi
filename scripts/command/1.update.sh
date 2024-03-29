#!/bin/bash

# update OS files
sudo apt update && sudo apt upgrade -y
#sudo rpi-update
echo "Done. Reboot needed"
#reboot #needed to load new kernel
printf "Do you want to reboot now? \n Y or N"
read -r decision

if $decision '==' Y; then
    sudo reboot now
else
    exit
fi