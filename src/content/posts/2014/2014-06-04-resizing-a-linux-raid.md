---
ID: "831"
post_author: "2"
post_date: "2014-06-04 07:12:32"
post_date_gmt: "2014-06-04 07:12:32"
post_title: Resizing a Linux RAID
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: resizing-a-linux-raid
to_ping: ""
pinged: ""
post_modified: "2014-06-04 07:12:32"
post_modified_gmt: "2014-06-04 07:12:32"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=831
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Resizing a Linux RAID
date: 2014-06-04
tags: boot, device, drive, filesystem, idea, linux, partition, setup
revised: 2021-12-22
---

It is possible to migrate the whole array to larger drives
(e.g. 250 GB to 1 TB) by replacing one by one. In the end the number
of devices will be the same, the data will remain intact, and you will
have more space available to you.

### Extending an existing RAID array

In order to increase the usable size of the array, you must increase
the size of all disks in that array. Depending on the size of your
disks, this may take days to complete. It is also important to note
that while the array undergoes the resync process, it is vulnerable
to irrecoverable failure if another drive were to fail. It would (of
course) be a wise idea to completely back up your data before continuing.

First, choose a drive and completely remove it from the array

```
mdadm -f /dev/md0 /dev/sdd1
mdadm -r /dev/md0 /dev/sdd1
````

Next, partition the new drive so that you are using the amount of
space you will eventually use on all new disks. For example, if you
are going from 100 GB drives to 250 GB drives, you will want to
partition the new 250 GB drive to use 250 GB, not 100 GB. Also,
remember to set the partition type to **0xDA** \- Non-fs data (or
**0xFD**, Linux raid autodetect if you are still using the deprecated
autodetect).

```
fdisk /dev/sde
```

Now add the new disk to the array:

```
mdadm --add /dev/md0 /dev/sde1
```

Allow the resync to fully complete before continuing. You will now
have to repeat the above steps for ***each**\* disk in your array.
Once all of the drives in your array have been replaced with larger
drives, we can grow the space on the array by issuing:

```
mdadm --grow /dev/md0 --size=max
```

The array now represents one disk using all of the new available space.

If the array has a write-intent bitmap, it is strongly recommended that
you remove the bitmap **before** increasing the size of the array.
Failure to observe this precaution can lead to the destruction of the
array if the existing bitmap is insufficiently large, especially if
the increased array size necessitates a change to the bitmap's chunksize.

```
 mdadm --grow /dev/mdX --bitmap none
 mdadm --grow /dev/mdX --size max
 mdadm --wait /dev/mdX
 mdadm --grow /dev/mdX --bitmap internal
```

If the system relies on the disks in the array for booting the OS
(a common approach is to keep /boot in a RAID 1 array, i.e. md0,
across all the disks in the array) then you might need to manually
reinstall the bootloader on each of the new disks, because the array
synchronization does not sync the MBR. This should be done directly
on each disk and not on the array itself (/dev/mdX), and is safe to
do with the array online. For example, to re-install GRUB on the
first disk:

```
grub
grub> root (hd0,0)
grub> setup (hd0)
```

You need to repeat this for each new disk that should contain the
bootloader. If you forget to do so, and find that you cannot boot
the system after replacing all the disks, you can boot from a rescue
CD/DVD/USB in order to install the bootloader as instructed above.

### Extending the filesystem

Now that you have expanded the underlying partition, you must now
resize your filesystem to take advantage of it.

You may want to perform an fsck on the file system first to make sure
there are no underlying issues before attempting to resize the file system

```
 fsck /dev/md0
```

For an ext2/ext3 filesystem:

```
resize2fs /dev/md0
```

For a reiserfs filesystem:

```
resize_reiserfs /dev/md0
```

Please see filesystem documentation for other filesystems.

### LVM: Growing the PV

LVM (logical volume manager) abstracts a logical volume
(that a filesystem sits on) from the physical disk. If you are used
to LVM then you are likely used to growing LVs (logical volumes), but
what we grow here is the PV (physical volume) that sits on the
_md_ device (RAID array).

For further LVM documentation, please see the
[Linux LVM HOWTO](http://tldp.org/HOWTO/LVM-HOWTO/)

Growing the physical volume is trivial:

```
pvresize /dev/md0
```

A before-and-after example is:

```
root@barcelona:~# pvdisplay
  \-\-\- Physical volume ---
  PV Name               /dev/md0
  VG Name               server1_vg
  PV Size               931.01 GB / not usable 558.43 GB
  Allocatable           yes
  PE Size (KByte)       4096
  Total PE              95379
  Free PE               42849
  Allocated PE          52530
  PV UUID               BV0mGK-FRtQ-KTLv-aW3I-TllW-Pkiz-3yVPd1

root@barcelona:~# pvresize /dev/md0
  Physical volume "/dev/md0" changed
  1 physical volume(s) resized / 0 physical volume(s) not resized

root@barcelona:~# pvdisplay
  \-\-\- Physical volume ---
  PV Name               /dev/md0
  VG Name               server1_vg
  PV Size               931.01 GB / not usable 1.19 MB
  Allocatable           yes
  PE Size (KByte)       4096
  Total PE              238337
  Free PE               185807
  Allocated PE          52530
  PV UUID               BV0mGK-FRtQ-KTLv-aW3I-TllW-Pkiz-3yVPd1
```

The above is the PV part after md0 was grown from ~400GB to ~930GB
(a 400GB disk to a 1TB disk). Note the _PV Size_ descriptions before
and after.

Once the PV has been grown (and hence the size of the VG, volume
group, will have increased), you can increase the size of an LV
(logical volume), and then finally the filesystem, eg:

```
lvextend -L +50G -n home\_lv server1\_vg
resize2fs /dev/server1\_vg/home\_lv
```

The above grows the _home_lv_ logical volume in the _server1_vg_ 
volume group by 50GB. It then grows the ext2/ext3 filesystem on that
LV to the full size of the LV, as per _Extending the filesystem_ above.

Source: [https://raid.wiki.kernel.org/index.php/Growing](https://raid.wiki.kernel.org/index.php/Growing "Raid Wiki")
