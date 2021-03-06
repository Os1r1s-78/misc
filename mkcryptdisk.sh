#!/bin/bash
# Author Dario Clavijo 2016

set -x

DISK=$1
KEYFILE=$2

cryptsetup luksClose $DISK
cryptsetup -y --verbose --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat $DISK
cryptsetup luksAddKey /dev/$DISK $KEYFILE
cryptsetup --key-file $KEYFILE luksOpen /dev/$DISK $DISK
mkfs.btrfs /dev/mapper/$DISK
mkdir /media/$DISK
#mount /dev/mapper/$DISK /media/$DISK

BLKID=$(blkid /dev/$DISK -o value | head -n 1)
echo "$DISK UUID=$BLKID $KEYFILE  luks" >> /etc/crypttab
BLKID=$(blkid /dev/mapper/$DISK -o value | head -n 1)
echo "UUID=$BLKID /media/$DISK btrfs defaults,compress=lzo 0 0" >> /etc/fstab

#mount -a

