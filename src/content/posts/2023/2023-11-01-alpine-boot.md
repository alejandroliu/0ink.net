---
title: Alpine boot menu
tags: alpine, boot, configuration, device, drive, filesystem, linux, network, partition, speed
---
This article is an update to my 
[[../2020/2020-10-04-alpine-boot-switcher.md|Alpine Boot Switcher]] article.

***
Contents:

[TOC]
***

The weakness of that approach was that you needed to be on a running system
to select the active kernel.  So, if you switched to a broken kernel then
you wouldn't be able to revert back without having to get the media device out
and modifying the file system to switch to a different kernel.

The approach described here makes use of syslinux or grub menu system to allow you to
select a new kernel.  It requires modifying the `init` script in the
`initramfs` image so that you can specifically select the right APK boot repository
otherwise it will use the first one found in the boot file system.

This solution is suitable for physical and virtualized systems using BIOS and UEFI
boot methods.

The high level approach is:

- prepare a bootable USB or virtual disk image.
- during system operation, use the `inst_iso` script to install a new
  Alpine release.
- You can use the `mkmenu` script to select the new kernel or ...
- Re-boot the system, syslinux (on BIOS systems) or grub (on UEFI) systems
  will show a menu to let you select the boot kernel or boot a default
  kernel after 10 seconds (unless configured for a different time-out).
- If the boot was succesful, you can use `mkmenu` to make the current
  kernel the default kernel.
- If the boot fails, then you can hard boot the system and use the boot
  menu to select a known working kernel.

# Preparing boot device

Use the `mkuub` script to create a bootable USB drive or a bootable disk image.

The USB drive can be used
on a physical system and supports UEFI and BIOS boot methods (BIOS boot is untested).  

The bootable disk image is meant to be used on a virtualized environment.  I have tested
it on `virsh on kvm` and uses the BIOS boot method.  It has UEFI boot support files but
I have not tested this.

Usage:

```
    ./mkuusb.sh [options] isofile [usbdev]
```

Options:

* `--serial` : Enable serial console
* `--ovl=ovlfile` : overlay file to use
* `--boot-label=label` : boot partition label \
  Defaults to a random label unless ovl is specifed.
  In that case, it will take the label from the filesystem mounted as
  `/media/boot` from `/etc/fstab`.
* `--boot-size=size` : boot partition size \
  If not specified it will default to the entire drive
  or up to half the drive (if data partition is enabled)
  up to 8GB.
* `--data` : create a data partition
* `--data-label=label` : label for data partition_disc \
  Defaults to a random label unless ovl is specifed
  then will take the label from the filesystem mounted as
  `/media/data` from `/etc/fstab`.
* `--data-size=size` : data partition size \
  size defaults to the remaining of the disk
* `isofile `: ISO file to use as the base alpine install
* `usbhdd` : `/dev/path` to the thumb drive that will be installed. \
  It will try to use a suitable default by looking an unused drive from
  the currently connected drives on the system.  Otherwise a target
  image file can be specified using:
  * `img:path/to/image/file[,size]`

if `--serial` was used, the boot menu will be configure to use the first
serial port (Usually `COM1`) with a speed of 115200.  So you can use
a serial console or the normal display to select the desired kernel.

When configured using `serial`, kernel boot message would be displayed on
the serial console.


# Booting the system

After creating the boot device, you can connected to a physical server or
in the case of a bootable image add it to a virtual machine configuration.

Booting the system will show a boot menu letting you select a kernel.  If
nothing is selected after the time-out period, a configured default
will be used.

# Adding a new kernel

During normal operation, you may want to upgrade to a new kernel.  To do this
you can use the script:

- `$bootmedia/scripts/inst_iso.sh` _file-or-url_

You can pass a iso file name or the URL of an ISO over the network.  If using
an URL, the script will download the image first.

This will prepare the environment to include the new kernel and add a menu
entry to boot the new kernel.  The default kernel remains as the currently
running kernel.

At this point, the system can be rebooted. You can then use the
boot menu to select the latest kernel manually.

If the new kernel fails to boot succesfully, then you may need to hard boot
the system.

Since the default kernel was not changed, it should boot to the last working
kernel and proceed normally.

# After a succesful reboot

If the new kernel was succesfully booted, you can use the command:

- `$bootmedia/mkmenu.sh`

to make the currently running kernel the default.

# Alternative workflow

Alternatively, after the new kernel is installed, you can use the command:

- `$bootmedia/mkmenu.sh --latest`

to make the new kernel the default one.  You can then re-boot the system
and if everything goes fine, you are done.

If the system fails to boot then you probably will need to do a hard boot of
the system and use the boot menu to select a working Alpine Linux kernel.

After a succesful boot, then you can use the command:

- `$bootmedia/mkmenu.sh`

To make the current running kernel the default.


# Removing installed kernels

Alpine Linux boot images are installed in their own folders.  If you want
to remove a kernel, just remove the folder that you want to un-install and
run `mkemnu.sh` again to update the boot menu.

# Downloads

The code can be found in my repository:

- [github](https://github.com/TortugaLabs/mab/tree/main/uub)

Alpine Linux boot images:

- [Alpine Linux ISO downloads](https://alpinelinux.org/downloads/)



