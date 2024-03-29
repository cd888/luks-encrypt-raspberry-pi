#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

rasp_boot_dir="/boot/firmware"

mkinitramfs -o ${rasp_boot_dir}/initramfs.gz
lsinitramfs ${rasp_boot_dir}/initramfs.gz |grep -P "sbin/(cryptsetup|resize2fs|fdisk|dumpe2fs|expect)"
#sudo reboot
printf "Do you want to reboot now? \n Y or N"
read -r decision

if $decision '==' Y; then
   sudo reboot now
else
   exit
fi