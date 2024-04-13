#!/bin/sh

e2fsck -f /dev/mmcblk0p2
echo "Resizing root system"
resize2fs -f -M -p /dev/mmcblk0p2
echo "Resizing complete"

BLOCK_COUNT="$(dumpe2fs /dev/mmcblk0p2 | sed "s/ //g" | sed -n "/Blockcount:/p" | cut -d ":" -f 2)"
echo "Block count: $BLOCK_COUNT"
SHASUM_ROOT="$(dd bs=4k count=$BLOCK_COUNT if=/dev/mmcblk0p2 | sha256sum)"
echo "Moving root to external drive"
dd bs=4k count=$BLOCK_COUNT if=/dev/mmcblk0p2 of=/dev/$1
echo "Move complete"
SHASUM_EXT="$(dd bs=4k count=$BLOCK_COUNT if=/dev/$1 | sha256sum)"

if [ "$SHASUM_ROOT" == "$SHASUM_EXT" ]; then
	echo "1.SHA sums match."
	echo "Start encryption of SD Card"
	cryptsetup --cipher aes-cbc-plain64 --hash sha256 luksFormat --type luks2 /dev/mmcblk0p2
	echo "Encryption complete"
	echo "Open Partition"
	cryptsetup open --type luks2 /dev/mmcblk0p2 sdcard
	echo "Move root back to SD Card"
	dd bs=4k count=$BLOCK_COUNT if=/dev/$1 of=/dev/mapper/sdcard
	SHASUM_NEWROOT="$(dd bs=4k count=1516179 if=/dev/mapper/sdcard | sha256sum)"
	if [ "$SHASUM_ROOT" == "$SHASUM_EXT" ]; then
		echo "2.SHA sums match."
		e2fsck -f /dev/mapper/sdcard
		echo "Restoring size of SD card back to normal"
		resize2fs -p -f /dev/mapper/sdcard
		echo "Done. Reboot and rebuild initramfs."
	else
		echo "2. SHA sums error."
	fi
else
	echo "1. SHA sums error."
fi
