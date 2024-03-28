#!/bin/bash

#https://github.com/johnshearing/MyEtherWalletOffline/blob/master/Air-Gap_Setup.md#setup-luks-full-disk-encryption
#https://robpol86.com/raspberry_pi_luks.html
#https://www.howtoforge.com/automatically-unlock-luks-encrypted-drives-with-a-keyfile

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

install_command="apt install"
install_dir="/boot/install"
rasp_boot_dir="/boot/firmware"
root_dev_name="mmcblk0p2"

$install_command busybox cryptsetup initramfs-tools -y
$install_command expect --no-install-recommends -y
cp ${install_dir}/initramfs-rebuild /etc/kernel/postinst.d/initramfs-rebuild
cp ${install_dir}/resize2fs /etc/initramfs-tools/hooks/resize2fs
chmod +x /etc/kernel/postinst.d/initramfs-rebuild
chmod +x /etc/initramfs-tools/hooks/resize2fs

echo 'CRYPTSETUP=y' | tee --append /etc/cryptsetup-initramfs/conf-hook > /dev/null
mkinitramfs -o ${rasp_boot_dir}/initramfs.gz

lsinitramfs ${rasp_boot_dir}/initramfs.gz | grep -P "sbin/(cryptsetup|resize2fs|fdisk|dumpe2fs|expect)"
#Make sure you see sbin/resize2fs, sbin/cryptsetup, and sbin/fdisk in the output.

echo 'initramfs initramfs.gz followkernel' | tee --append ${rasp_boot_dir}/config.txt > /dev/null

sed -i '$s/$/ cryptdevice=\/dev\/mmcblk0p2:sdcard/' ${rasp_boot_dir}/cmdline.txt

ROOT_CMD="$(sed -n 's|^.*root=\(\S\+\)\s.*|\1|p' ${rasp_boot_dir}/cmdline.txt)"
sed -i -e "s|$ROOT_CMD|/dev/mapper/sdcard|g" ${rasp_boot_dir}/cmdline.txt

FSTAB_CMD="$(blkid | sed -n '/dev\/mmcblk0p2/s/.*\ PARTUUID=\"\([^\"]*\)\".*/\1/p')"
sed -i -e "s|PARTUUID=$FSTAB_CMD|/dev/mapper/sdcard|g" /etc/fstab

echo "sdcard /dev/${root_dev_name} none luks" | tee --append /etc/crypttab > /dev/null

echo "Done. Reboot with: sudo reboot"
#reboot
