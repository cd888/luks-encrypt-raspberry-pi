# LUKS Encrypt Raspberry PI

## What You Will Need

1. Raspberry PI
2. SDCard with Raspbian OS Lite installed
3. Flash drive connected to the RPI (to copy data from root partition during encrypt)
4. Bash scripts from this repo

## Install OS and Update Kernel

1. Burn the Raspberry PI OS to the SDCard w/ `BalenaEtcher` or `Raspberry PI Imager`

2. Copy install scripts into `/boot/firmware/install/`

3. Boot into the Raspberry PI and run `sudo /boot/install/1.update.sh`

4. `sudo reboot`  to load the updated kernel

## Install Enc Tools and Prep `initramfs`

1. Run script `/boot/install/2.disk_encrypt.sh`

2. `sudo reboot` to drop into the initramfs shell.

## Mount and Encrypt

1. Mount master block device to `/tmp/boot/firmware/`

   ```shell
   mkdir /tmp/boot/firmware/
   mount /dev/mmcblk0p1 /tmp/boot/firmware/
   ```

2. Run the encryption script, passing your flash drive descriptor:

   ```shell
   /tmp/boot/firmware/install/3.disk_encrypt_initramfs.sh [sda|sdb|etc] 
   ```

3. When LUKS encrypts the root partition it will ask you to type `YES` (in uppercase).

4. Create a decryption password (you will be asked twice).

5. LUKS will ask for the decryption password again to copy the data back from the flash drive to the root partition.

6. `reboot -f` to drop back into initramfs.

## Unlock and Reboot to OS

1. Mount master block device at `/tmp/boot/firmware/`
   
   ```shell
   mkdir /tmp/boot/firmware/
   mount /dev/mmcblk0p1 /tmp/boot/firmware/
   ```

2. Open the LUKS encrypted disk:
   
   ```shell
   /tmp/boot/firmware/install/4.luks_open.sh
   ```

3. Type in your decryption password again.

4. `exit` to quit BusyBox and boot normally.

## Rebuild `initramfs` for Normal Boot

1. Run script: `/boot/firmware/install/5.rebuild_initram.sh`

2. `sudo reboot` into Raspberry PI OS.

3. You should be asked for your decryption password every time you boot.
   
   ```shell
   Please unlock disc sdcard: _
   ```

____

## References

- [Source 1:](https://forums.raspberrypi.com/viewtopic.php?t=219867)
- [Source 2:](https://github.com/johnshearing/MyEtherWalletOffline/blob/master/Air-Gap_Setup.md#setup-luks-full-disk-encryption)
- [Source 3:](https://robpol86.com/raspberry_pi_luks.html)
- [Source 4:](https://www.howtoforge.com/automatically-unlock-luks-encrypted-drives-with-a-keyfile)
