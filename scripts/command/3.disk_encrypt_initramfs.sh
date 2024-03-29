#!/bin/bash

root_dev_name_loc="/dev/mmcblk0p2"

e2fsck -f $root_dev_name_loc
resize2fs -fM $root_dev_name_loc

BLOCK_COUNT="$(dumpe2fs ${root_dev_name_loc} | sed "s/ //g" | sed -n "/Blockcount:/p" | cut -d ":" -f 2)"
echo "Block count: ${BLOCK_COUNT}"
SHA2SUM_ROOT="$(dd bs=4k count=${BLOCK_COUNT} if=${root_dev_name_loc} | sha224sum)"
dd bs=4k count="$BLOCK_COUNT" if=$root_dev_name_loc of=/dev/$1
SHA2SUM_EXT="$(dd bs=4k count=${BLOCK_COUNT} if=/dev/$1 | sha224sum)"

if [ "$SHA2SUM_ROOT" == "$SHA2SUM_EXT" ]; then
	echo "1.Sha2sums match."
	cryptsetup --cipher aes-xts-plain64 --hash sha256 luksFormat --type luks2 ${root_dev_name_loc}
	cryptsetup open --type luks2 ${root_dev_name_loc} sdcard
	dd bs=4k count="$BLOCK_COUNT" if=/dev/"$1" of=/dev/mapper/sdcard
	SHA2SUM_NEWROOT="$(dd bs=4k count=1516179 if=/dev/mapper/sdcard | sha224sum)"
	if [ "$SHA2SUM_NEWROOT" == "$SHA2SUM_EXT" ]; then
		echo "2.Sha2sums match."
		e2fsck -f /dev/mapper/sdcard
		resize2fs -f /dev/mapper/sdcard
		echo "Done. Reboot and rebuild initramfs."
		printf "Do you want to reboot now? \n Y or N"
		read -r decision
		if $decision '==' Y; then
    		sudo reboot now
		fi
	else
		echo "2.Sha2sums error."
	fi
else
	echo "1.Sha2sums error."
fi
