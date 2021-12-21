---
title: Resizing Virtual Disks with virsh
---

I am currently using `libvirt` for managing my VMs.  For virtual discs
I am using `LVM2` volumes.  On a regular basis I need to resize
these virtual discs, but not that often that I can do this from
memory.  This is a short procedure to do this:

```
ls -l /dev/vgX/lvX		# note down the major/minor numbers for later
lvextend -L +50G /dev/vgX/lvX	# adding 50GB to this volume
cat /proc/partitions		# look up the size (in blocks) using major/minor numbers
virsh blockresize --path /dev/vgX/lvX --size SIZE_FROM_PROC_PARTITIONS vmname
```

Then on the running system you can do:

```
cat /proc/partitions		# Make sure that size is right
xfs_growfs /mount/point		# On-line partition re-size
```
