---
title: Alpine Boot switcher
tags: boot, directory, drive, partition
---

I boot from a USB boot drive using UEFI.  Because of the UEFI boot,
it just a matter of copying the files from the [alpine][alpine]
ISO to a USB thumbdrive VFAT32 partition.  Partition may be set to
EFI (but this doesn't seem to be required).

Since I would like to switch between different [alpine][alpine] versions,
I wrote a script to let me have multiple [alpine][alpine] versions and
switch between them.  The boot partition can be kept `ro` as the script
will automatically remount `rw`.

In your boot/EFI partition, you need to have these two scripts:

- [select.sh](https://github.com/alejandroliu/0ink.net/blob/master/snippets/alpine-boot-switcher/select.sh)
- [fixup.sh](https://github.com/alejandroliu/0ink.net/blob/master/snippets/alpine-boot-switcher/fixup.sh)

The `select.sh` script is the main script.  `fixup.sh` is called from
`select.sh` to tweak the boot command line parameters.  I use it to add
`dom0_mem=2048M` arguments to the boot command line so that `xen`
reserves memory for guests.

# Usage:

## Install an ISO image

Download a iso image from the [alpine][alpine] repository and enter:

```
sh select.sh --install <iso-file>
```

This will extract the contents of the `<iso-file>` and use `fixup.sh`
to apply any necessary tweaks.  The new ISO file will be placed
in a directory named according to the alpine version.


## Enabling a version

```
sh select.sh <directory>
```

Makes the [alpine][alpine] version in `<directory>` the current active
version for boot.



[alpine]: https://alpinelinux.org/

