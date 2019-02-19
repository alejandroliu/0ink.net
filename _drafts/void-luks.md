---
title: Encrypting /home in Void Linux
---

# Encrypting /home in Void Linux

Generate a passphrase and save it a safe place for later.

```
xbps-install -S lvm2 cryptsetup
cryptsetup luksFormat /dev/xda2
cryptsetup luksOpen /dev/xda2 crypt-pool
vgcreate pool /dev/mapper/crypt-pool
lvcreate --name home0 -L 20G pool


```
Add `rd.luks.crypttab=1 rd.luks=1` to the kernel command line.


Create the key file in the unencrypted /boot partition

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


