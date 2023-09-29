---
title: File system encryption in Alpine Linux
tags: alpine, boot, configuration, device, encryption, filesystem, idea, linux, service
service
---
This is similar to my previous article
[[../2019/2019-02-28-encrypting-fs-in-void.md|Encrypting Filesystem in Void Linux]]
but for Alpine Linux

The point of this recipe is to create a encrypted file sytem
so that when the disc is disposed, it does not need to be
securely erased.  This is particularly important for SSD devices
since because of block remapping (for wear levelling) data can't
be overwritten consistently.

The idea is that the boot/root filesystem containing the encryption
keys are stored in a different device as the encrypted file system.


# Create block devices

```bash
apk add lvm2 cryptsetup

dd if=/dev/urandom of=/etc/crypto_keyfile.bin bs=1024 count=4
chmod 000 /etc/crypto_keyfile.bin
cryptsetup luksFormat /dev/xda2 /etc/crypto_keyfile.bin
cryptsetup luksOpen --key-file=/etc/crypto_keyfile.bin /dev/xda2 crypt-pool

```

Look up the UUID

```bash
blkid /dev/xda2
```

Edit `dmcrypt` service configuration in `/etc/conf.d/dmcrypt`:


```bash
target=crypt-pool
source="UUID=xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
key=/etc/crypto_keyfile.bin

```

And enable it with this command:

```
rc-update add dmcrypt boot

```

At this point it would be good to backup:

- `/etc/conf.d/dmcrypt`
- `/etc/crypto_keyfile.bin`


Reboot and make sure that the block device gets created on start-up.

Add to LVM:

```bash
vgcreate pool /dev/mapper/crypt-pool
lvcreate --name home0 -L 20G pool

```

Create your file-system and add it to `/etc/fstab`.

