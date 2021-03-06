#!/bin/bash
#Author Dario Clavijo
set -x
VERSION=$(uname -r)
KVDO=$1
apt-get install linux-headers-$VERSION build-essential -y
git clone https://github.com/dm-vdo/kvdo $KVDO
if [ $? -ne 0 ]; then
	cd $KVDO
	git pull
else
	cd $KVDO
fi
make -C /usr/src/linux-headers-$VERSION/ M=$(pwd) -j 16
if [ $? -eq 0 ]; then
	modprobe -r kvdo
	modprobe -r uds 
	#rmmod kvdo
	#rmmod uds
	insmod uds/uds.ko
	insmod vdo/kvdo.ko
	cp uds/uds.ko /lib/modules/$VERSION/kernel/drivers/misc/
	cp vdo/kvdo.ko /lib/modules/$VERSION/kernel/drivers/misc/
	depmod -a
	modprobe kvdo
	if [ $? -eq 0 ]; then
		update-initramfs -u
	fi
fi
