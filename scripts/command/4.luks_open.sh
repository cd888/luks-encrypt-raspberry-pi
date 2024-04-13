#!/bin/sh

echo "Open root"
cryptsetup open --type luks2 /dev/mmcblk0p2 sdcard
exit
