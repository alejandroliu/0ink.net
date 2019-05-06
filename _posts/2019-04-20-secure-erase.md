---
title: Secure erase of disc drives
---

This article is about erasing disc drives securely.  Specially for SSD
drives, writing zeros or random data to discs is not good enough and
counterproductive.

One way to do secure erase (for disposal) is to begin with an encrypted
disc.  However, after the fact the following options are possible:

# ATA Secure Erase

You should use the drive's security erase feature.

Make sure the drive Security is not frozen. If it is, it may help to suspend and resume the computer.

```
$ sudo hdparm -I /dev/sdX | grep frozen
       not     frozen 
```

The (filtered) command output means that this drive is ”not frozen” and you can continue.

Set a User Password (this password is cleared too, the exact choice does not matter).

```
sudo hdparm --user-master u --security-set-pass Eins /dev/sdX
```

Issue the ATA Secure Erase command

```
sudo hdparm --user-master u --security-erase Eins /dev/sdX
```


Notes:

- /dev/sdX is the SSD as a block device that you want to erase.
- Eins is the password chosen in this example.

See the ATA Secure Erase article in the [Linux kernel wiki][wk1] for
complete instructions including troubleshooting.

If for some reason you need to remove the password use:

```
sudo hdparm --security-disable Eins
```

# blkdiscard

`util-linux 2.23` offers [blkdiscard][man1] which discards data without
secure-wiping them.  This has been tested to work over SATA and mmcblk
but not USB.

An excerpt from the manual page of `blkdiscard(8)`:

## NAME

blkdiscard - discard sectors on a device

## SYNOPSIS

```
blkdiscard [-o offset] [-l length] [-s] [-v] device
```

## DESCRIPTION

`blkdiscard` is used to discard device sectors. This is useful for
solid-state drivers (SSDs) and thinly-provisioned storage. Unlike
`fstrim(8)` this command is used directly on the block device.

By default, `blkdiscard` will discard all blocks on the device. Options
may be used to modify this behavior based on range or size, as explained
below.

The device argument is the pathname of the block device.

**WARNING: All data in the discarded region on the device will be lost!**


# Use TRIM

To enable TRIM:

```
sudo vi /etc/fstab
```

Change `ext4 errors=remount-ro 0" into "ext4 discard,errors=remount-ro 0`.
**(Add discard)**

Save and reboot, TRIM should now be enabled.

Check if TRIM is enabled:

```
sudo dd if=/dev/urandom of=tempfile count=100 bs=512k oflag=direct
sudo hdparm --fibmap tempfile
```

Use the first begin_LBA address.

```
hdparm --read-sector [begin_LBA] /dev/sda
```

Now it should return numbers and characters. Remove the file and sync.

```
rm tempfile
sync
```

Now, run the following command again. If it returns zeros TRIM is enabled.

```
hdparm --read-sector [begin_LBA] /dev/sda
```

Another option is to use the [fstrim][man2] command.

# Old fashioned writes

This is what I used to do for magnetic discs.  Note, that this is
discouraged for SSD devices:

First I create some random data to use:
```
dd if=/dev/urandom of=/var/tmp/random bs=1M count=128
```
Then we write random data to disc:
```
(while : ; do dd if=/var/tmp/random bs=4k ; done ) | pv | dd of=/dev/sdX bs=4k
```
The `pv` part of the pipe is **optional**.

Afterwards:
```
dd if=/dev/zero of=/dev/sdX bs=4k
```


[wk1]: https://ata.wiki.kernel.org/index.php/ATA_Secure_Erase
[man1]: http://man7.org/linux/man-pages/man8/blkdiscard.8.html
[man2]: http://man7.org/linux/man-pages/man8/fstrim.8.html
