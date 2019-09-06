#!/bin/sh
#
# Enter the void...
#
# Use this command:
#	wget https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/enter-void.sh
#	sudo sh enter-void.sh
#	or
#	sh enter-void.sh

mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o bind /dev /mnt/dev
mount -t devpts pts /mnt/dev/pts
cp -L /etc/resolv.conf /mnt/etc/
chroot /mnt bash -il
