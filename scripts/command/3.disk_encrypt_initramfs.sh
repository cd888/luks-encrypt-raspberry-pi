#!/bin/bash

root_dev_name_loc="/dev/mmcblk0p2"

e2fsck -f $root_dev_name_loc
resize2fs -fM $root_dev_name_loc

BLOCK_COUNT="$(dumpe2fs ${root_dev_name_loc} | sed "s/ //g" | sed -n "/Blockcount:/p" | cut -d ":" -f 2)"
echo "Block count: ${BLOCK_COUNT}"
SHA1SUM_ROOT="$(dd bs=4k count=${BLOCK_COUNT} if=${root_dev_name_loc} | sha1sum)"
dd bs=4k count="$BLOCK_COUNT" if=$root_dev_name_loc of=/dev/$1
SHA1SUM_EXT="$(dd bs=4k count=${BLOCK_COUNT} if=/dev/$1 | sha1sum)"

if [ "$SHA1SUM_ROOT" == "$SHA1SUM_EXT" ]; then
	echo "1.Sha1sums match."
	cryptsetup --cipher aes-xts:sha256 luksFormat ${root_dev_name_loc}
	cryptsetup luksOpen ${root_dev_name_loc} sdcard
	dd bs=4k count="$BLOCK_COUNT" if=/dev/$1 of=/dev/mapper/sdcard
	SHA1SUM_NEWROOT="$(dd bs=4k count=1516179 if=/dev/mapper/sdcard | sha1sum)"
	if [ "$SHA1SUM_NEWROOT" == "$SHA1SUM_EXT" ]; then
		echo "2.Sha1sums match."
		e2fsck -f /dev/mapper/sdcard
		resize2fs -f /dev/mapper/sdcard
		echo "Done. Reboot and rebuild initramfs."
	else
		echo "2.Sha1sums error."
	fi
else
	echo "1.Sha1sums error."
fi
