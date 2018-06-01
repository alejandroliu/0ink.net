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
...
---

This is for SATA and IDE interfaces that do not automatically detect added/removed devices.

<h2>Scanning for newly added discs:</h2>

<pre><code>echo "- - -" &gt; /sys/class/scsi_host/host0/scan
</code></pre>

<h2>safely removing a disk</h2>

<pre><code>echo 1 &gt; /sys/block/sda/device/delete
</code></pre>

<h2>Other notes...</h2>

In the <em>HP MicroServer</em>, we can identify the host to scan by:

<pre><code>head -1 /sys/class/scsi_host/host*/proc_name
</code></pre>

And look for the <code>pata_atiixp</code>.  Should show <code>ahci</code> and <code>usb-storage</code> too.

