---
title: Encrypting FileSystem in Void Linux
---

The point of this recipe is to create a encrypted file sytem
so that when the disc is disposed, it does not need to be
securely erased.  This is particularly important for SSD devices
since because of block remapping (for wear levelling) data can't
be overwritten consistently.

The idea is that the boot/root filesystem containing the encryption
keys are stored in a different device as the encrypted file system.

* * *

Generate a passphrase and save it a safe place for later.

# Create block devices

```
xbps-install -S lvm2 cryptsetup
cryptsetup luksFormat /dev/xda2
cryptsetup luksOpen /dev/xda2 crypt-pool
vgcreate pool /dev/mapper/crypt-pool
lvcreate --name home0 -L 20G pool


```
Add `rd.luks.crypttab=1 rd.luks=1` to the kernel command line.

# Create a decryption key

Create the key file in the unencrypted `/` partition

```
dd if=/dev/urandom of=/crypto_keyfile.bin bs=1024 count=4
chmod 000 /crypto_keyfile.bin
cryptsetup -v luksAddKey /dev/xda2 /crypto_keyfile.bin
```

Look up the UUID

```
blkid /dev/xda2
```

Create entry in `/etc/crypttab`:

```
crypt-pool 	UUID=xxxxxxxxxxxxxxxx /crypto_keyfile.bin luks
```

Create `/etc/dracut.conf.d/10-crypt.conf`

```
install_items+="/etc/crypttab /crypto_keyfile.bin"
```

Update initrd:

```
xbps-reconfigure -f linux4.19
```

Update boot menu entries:

```
bash /boot/mkmenu.sh
```

At this point it would be good to save:

- `/etc/crypttab`
- `/crypto_keyfile.bin`
- Optionally, passphrase

* * *

Reboot and make sure that the block device gets created on start-up.

Create your file-system and add it to `/etc/fstab`.
