---
ID: "91"
post_author: "2"
post_date: "2013-05-18 09:24:47"
post_date_gmt: "2013-05-18 09:24:47"
post_title: SATA/IDE warm plug/unplug
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: closed
post_password: ""
post_name: sataide-warm-plugunplug
to_ping: ""
pinged: ""
post_modified: "2013-05-18 09:24:47"
post_modified_gmt: "2013-05-18 09:24:47"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=91
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: SATA/IDE warm plug/unplug
date: 2013-05-18
---

This is for SATA and IDE interfaces that do not automatically detect added/removed devices.

## Scanning for newly added discs:

```
echo "- - -" > /sys/class/scsi_host/host0/scan

```

## safely removing a disk

```
echo 1 > /sys/block/sda/device/delete

```

## Other notes...

In the _HP MicroServer_, we can identify the host to scan by:

```
head -1 /sys/class/scsi_host/host*/proc_name

```

And look for the `pata_atiixp`. Should show `ahci` and `usb-storage` too.
