#!/bin/sh

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Rebuilding initramfs"
mkinitramfs -o /boot/firmware/initramfs.gz
lsinitramfs /boot/firmware/initramfs.gz | grep -P "sbin/(cryptsetup|resize2fs|fdisk|dumpe2fs|expect)"
echo "Complete, reboot to take effect"
#sudo reboot
