#!/bin/bash

root_dev_name_loc="/dev/mmcblk0p2"

e2fsck -f /dev/mmcblk0p2
resize2fs -fM /dev/mmcblk0p2

BLOCK_COUNT="$(dumpe2fs /dev/mmcblk0p2 | sed "s/ //g" | sed -n "/Blockcount:/p" | cut -d ":" -f 2)"
echo "Block count: ${BLOCK_COUNT}"
SHA2SUM_ROOT="$(dd bs=4k count=${BLOCK_COUNT} if=/dev/mmcblk0p2 | sha256sum)"
dd bs=4k count="$BLOCK_COUNT" if=$root_dev_name_loc of=/dev/$1
SHA2SUM_EXT="$(dd bs=4k count=${BLOCK_COUNT} if=/dev/$1 | sha256sum)"

if [ "$SHA2SUM_ROOT" == "$SHA2SUM_EXT" ]; then
	echo "1.Sha2sums match."
	cryptsetup --cipher aes-xts-plain64 --hash sha256 luksFormat --type luks2 /dev/mmcblk0p2
	cryptsetup open --type luks2 /dev/mmcblk0p2 sdcard
	dd bs=4k count="$BLOCK_COUNT" if=/dev/"$1" of=/dev/mapper/sdcard
	SHA2SUM_NEWROOT="$(dd bs=4k count=1516179 if=/dev/mapper/sdcard | sha256sum)"
	if [ "$SHA2SUM_NEWROOT" == "$SHA2SUM_EXT" ]; then
		echo "2.Sha2sums match."
		e2fsck -f /dev/mapper/sdcard
		resize2fs -p -f /dev/mapper/sdcard
		echo "Done. Reboot and rebuild initramfs."
	else
		echo "2.Sha2sums error."
	fi
else
	echo "1.Sha2sums error."
fi
