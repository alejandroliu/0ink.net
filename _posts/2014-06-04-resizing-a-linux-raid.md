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
...
---

It is possible to migrate the whole array to larger drives (e.g. 250 GB to 1 TB) by replacing one by one. In the end the number of devices will be the same, the data will remain intact, and you will have more space available to you.

<h3 style="color: #000000"><span id="Extending_an_existing_RAID_array" class="mw-headline">Extending an existing RAID array</span></h3>

<p style="color: #000000">In order to increase the usable size of the array, you must increase the size of all disks in that array. Depending on the size of your disks, this may take days to complete. It is also important to note that while the array undergoes the resync process, it is vulnerable to irrecoverable failure if another drive were to fail. It would (of course) be a wise idea to completely back up your data before continuing.</p>

<p style="color: #000000">First, choose a drive and completely remove it from the array</p>

<pre style="color: #000000">mdadm -f /dev/md0 /dev/sdd1
mdadm -r /dev/md0 /dev/sdd1
</pre>

<p style="color: #000000">Next, partition the new drive so that you are using the amount of space you will eventually use on all new disks. For example, if you are going from 100 GB drives to 250 GB drives, you will want to partition the new 250 GB drive to use 250 GB, not 100 GB. Also, remember to set the partition type to <b>0xDA</b> - Non-fs data (or <b>0xFD</b>, Linux raid autodetect if you are still using the deprecated autodetect).</p>

<pre style="color: #000000">fdisk /dev/sde
</pre>

<p style="color: #000000">Now add the new disk to the array:</p>

<pre style="color: #000000">mdadm --add /dev/md0 /dev/sde1
</pre>

<p style="color: #000000">Allow the resync to fully complete before continuing. You will now have to repeat the above steps for *<strong>each</strong>* disk in your array. Once all of the drives in your array have been replaced with larger drives, we can grow the space on the array by issuing:</p>

<pre style="color: #000000">mdadm --grow /dev/md0 --size=max
</pre>

<p style="color: #000000">The array now represents one disk using all of the new available space.</p>

<p style="color: #000000">If the array has a write-intent bitmap, it is strongly recommended that you remove the bitmap <strong>before</strong> increasing the size of the array. Failure to observe this precaution can lead to the destruction of the array if the existing bitmap is insufficiently large, especially if the increased array size necessitates a change to the bitmap's chunksize.</p>

<pre style="color: #000000"> mdadm --grow /dev/mdX --bitmap none
 mdadm --grow /dev/mdX --size max
 mdadm --wait /dev/mdX
 mdadm --grow /dev/mdX --bitmap internal
</pre>

<p style="color: #000000">If the system relies on the disks in the array for booting the OS (a common approach is to keep /boot in a RAID 1 array, i.e. md0, across all the disks in the array) then you might need to manually reinstall the bootloader on each of the new disks, because the array synchronization does not sync the MBR. This should be done directly on each disk and not on the array itself (/dev/mdX), and is safe to do with the array online. For example, to re-install GRUB on the first disk:</p>

<pre style="color: #000000">grub
grub&gt; root (hd0,0)
grub&gt; setup (hd0)
</pre>

<p style="color: #000000">You need to repeat this for each new disk that should contain the bootloader. If you forget to do so, and find that you cannot boot the system after replacing all the disks, you can boot from a rescue CD/DVD/USB in order to install the bootloader as instructed above.</p>

<h3 style="color: #000000"><span id="Extending_the_filesystem" class="mw-headline">Extending the filesystem</span></h3>

<p style="color: #000000">Now that you have expanded the underlying partition, you must now resize your filesystem to take advantage of it.</p>

<p style="color: #000000">You may want to perform an fsck on the file system first to make sure there are no underlying issues before attempting to resize the file system</p>

<pre style="color: #000000"> fsck /dev/md0
</pre>

<p style="color: #000000">For an ext2/ext3 filesystem:</p>

<pre style="color: #000000">resize2fs /dev/md0
</pre>

<p style="color: #000000">For a reiserfs filesystem:</p>

<pre style="color: #000000">resize_reiserfs /dev/md0
</pre>

<p style="color: #000000">Please see filesystem documentation for other filesystems.</p>

<h3 style="color: #000000"><span id="LVM:_Growing_the_PV" class="mw-headline">LVM: Growing the PV</span></h3>

<p style="color: #000000">LVM (logical volume manager) abstracts a logical volume (that a filesystem sits on) from the physical disk. If you are used to LVM then you are likely used to growing LVs (logical volumes), but what we grow here is the PV (physical volume) that sits on the <i>md</i> device (RAID array).</p>

<p style="color: #000000">For further LVM documentation, please see the <a class="external text" style="color: #3366bb" href="http://tldp.org/HOWTO/LVM-HOWTO/" rel="nofollow">Linux LVM HOWTO</a></p>

<p style="color: #000000">Growing the physical volume is trivial:</p>

<pre style="color: #000000">pvresize /dev/md0
</pre>

<p style="color: #000000">A before-and-after example is:</p>

<pre style="color: #000000">root@barcelona:~# pvdisplay
  --- Physical volume ---
  PV Name               /dev/md0
  VG Name               server1_vg
  PV Size               931.01 GB / not usable 558.43 GB
  Allocatable           yes
  PE Size (KByte)       4096
  Total PE              95379
  Free PE               42849
  Allocated PE          52530
  PV UUID               BV0mGK-FRtQ-KTLv-aW3I-TllW-Pkiz-3yVPd1
</pre>

<pre style="color: #000000">root@barcelona:~# pvresize /dev/md0
  Physical volume "/dev/md0" changed
  1 physical volume(s) resized / 0 physical volume(s) not resized
</pre>

<pre style="color: #000000">root@barcelona:~# pvdisplay
  --- Physical volume ---
  PV Name               /dev/md0
  VG Name               server1_vg
  PV Size               931.01 GB / not usable 1.19 MB
  Allocatable           yes
  PE Size (KByte)       4096
  Total PE              238337
  Free PE               185807
  Allocated PE          52530
  PV UUID               BV0mGK-FRtQ-KTLv-aW3I-TllW-Pkiz-3yVPd1
</pre>

<p style="color: #000000">The above is the PV part after md0 was grown from ~400GB to ~930GB (a 400GB disk to a 1TB disk). Note the <i>PV Size</i> descriptions before and after.</p>

<p style="color: #000000">Once the PV has been grown (and hence the size of the VG, volume group, will have increased), you can increase the size of an LV (logical volume), and then finally the filesystem, eg:</p>

<pre style="color: #000000">lvextend -L +50G -n home_lv server1_vg
resize2fs /dev/server1_vg/home_lv
</pre>

<p style="color: #000000">The above grows the <i>home_lv</i> logical volume in the <i>server1_vg</i> volume group by 50GB. It then grows the ext2/ext3 filesystem on that LV to the full size of the LV, as per <i>Extending the filesystem</i> above.</p>

<p style="color: #000000">Source: <a title="Raid Wiki" href="https://raid.wiki.kernel.org/index.php/Growing">https://raid.wiki.kernel.org/index.php/Growing</a></p>
