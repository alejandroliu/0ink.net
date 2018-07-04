---
ID: "439"
post_author: "2"
post_date: "2013-06-01 08:27:05"
post_date_gmt: "2013-06-01 08:27:05"
post_title: Diskless Archlinux
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: diskless-archlinux
to_ping: ""
pinged: ""
post_modified: "2013-06-01 08:27:05"
post_modified_gmt: "2013-06-01 08:27:05"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=439
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Diskless Archlinux

---

<em>I am still to test this recipe</em>

<h1>Server Configuration</h1>

First of all, we must install the following components:

<ul>
<li>A DHCP server to assign IP addresses to our diskless nodes.</li>
<li>A TFTP server to transfer the boot image (a requirement of all PXE option roms).</li>
<li>A form of network storage (NFS or NBD) to export the Arch installation to the diskless node.</li>
</ul>

Note: dnsmasq is capable of simultaneously acting as both DHCP and TFTP server.

<h2>Network storage</h2>

The primary difference between using NFS and NBD is while with both you can in fact have multiple clients using the same installation, with NBD (by the nature of manipulating a filesystem directly) you'll need to use the copyonwrite mode to do so, which ends up discarding all writes on client disconnect. In some situations however, this might be highly desirable.

Install nfs-utils on the server.

<pre><code># pacman -Syu nfs-utils
</code></pre>

<h2>NFSv4</h2>

You'll need to add the root of your arch installation to your NFS exports:

<pre><code># vim /etc/exports
/srv/arch *(rw,fsid=0,no_root_squash,no_subtree_check)
</code></pre>

Next, start NFS.

<pre><code># systemctl start rpc-idmapd.service rpc-mountd.service
</code></pre>

<h2>NFSv3</h2>

<pre><code># vim /etc/exports
/srv/arch *(rw,no_root_squash,no_subtree_check,sync)
</code></pre>

Next, start NFSv3.

<pre><code># systemctl start rpc-mountd.service rpc-statd.service
</code></pre>

Note: If you're not worried about data loss in the event of network and/or server failure, replace sync with async--additional options can be found in the NFS article.

<h2>NBD</h2>

Install nbd .

<pre><code># pacman -Syu nbd
</code></pre>

Configure nbd.

<pre><code># vim /etc/nbd-server/config
[generic]
    user = nbd
    group = nbd
[arch]
    exportname = /srv/arch.img
    copyonwrite = false
</code></pre>

Note: Set copyonwrite to true if you want to have multiple clients using the same NBD share simultaneously; refer to man 5 nbd-server for more details.

Start nbd.

<pre><code># systemctl start nbd.service
</code></pre>

<h1>Client installation</h1>

Next we will create a full Arch Linux installation in a subdirectory on the server. During boot, the diskless client will get an IP address from the DHCP server, then boot from the host using PXE and mount this installation as its root.

<h2>Directory setup</h2>

<h3>NBD</h3>

Create a sparse file of at least 1 gigabyte, and create a btrfs filesystem on it (you can of course also use a real block device or LVM if you so desire).

<pre><code># truncate -s 1G /srv/arch.img
# mkfs.btrfs /srv/arch.img
# export root=/srv/arch
# mkdir -p "$root"
# mount -o loop,discard,compress=lzo /srv/arch.img "$root"
</code></pre>

Note: Creating a separate filesystem is required for NBD but optional for NFS and can be skipped/ignored.

<h2>Bootstrapping installation</h2>

Install devtools and arch-install-scripts , and run mkarchroot.

<pre><code># pacman -Syu devtools arch-install-scripts
# mkarchroot -f "$root" base mkinitcpio-nfs-utils nfs-utils
</code></pre>

Note: In all cases mkinitcpio-nfs-utils is still required--ipconfig used in early-boot is provided only by the latter.

Now the initramfs needs to be constructed. The shortest configuration, <code>#NFSv3</code>, is presented as a "base" upon which all subsequent sections modify as-needed.

<h3>NFSv3</h3>

<pre><code># vim "$root/etc/mkinitcpio.conf"
MODULES="nfsv3"
HOOKS="base udev autodetect net filesystems"
BINARIES=""
</code></pre>

Note: You'll also need to add the appropriate module for your ethernet controller to the MODULES array.
The initramfs now needs to be rebuilt; the easiest way to do this is via arch-chroot .

<pre><code># arch-chroot "$root" /bin/bash
(chroot) # mkinitcpio -p linux
(chroot) # exit
</code></pre>

<h3>NFSv4</h3>

Trivial modifications to the net hook are required in order for NFSv4 mounting to work (not supported by nfsmount--the default for the net hook).

<pre><code># sed s/nfsmount/mount.nfs4/ "$root/usr/lib/initcpio/hooks/net" | tee "$root/usr/lib/initcpio/hooks/net_nfs4"
# cp "$root/usr/lib/initcpio/install/{net,net_nfs4}"
</code></pre>

The copy of net is unfortunately needed so it does not get overwritten when mkinitcpio-nfs-utils is updated on the client installation.

From the base mkinitcpio.conf, replace the nfsv3 module with nfsv4, replace net with net_nfs4, and add /sbin/mount.nfs4 to BINARIES.

<h3>NBD</h3>

The mkinitcpio-nbd package needs to be installed on the client.

<pre><code># pacman --root "$root" --dbpath "$root/var/lib/pacman" -U mkinitcpio-nbd-0.4-1-any.pkg.tar
</code></pre>

You will then need to append nbd to your HOOKS array after net; net will configure your networking for you, but not attempt a NFS mount if nfsroot is not specified in the kernel line.

<h2>Client configuration</h2>

In addition to the setup mentioned here, you should also set up your hostname, timezone, locale, and keymap , and follow any other relevant parts of the Installation Guide .

<h1>Bootloader</h1>

<h2>Pxelinux</h2>

Install syslinux .

<pre><code># pacman -Syu syslinux
</code></pre>

Copy the pxelinux bootloader (provided by the syslinux package) to the boot directory of the client.

<pre><code># cp /usr/lib/syslinux/pxelinux.0 "$root/boot"
# mkdir "$root/boot/pxelinux.cfg"
</code></pre>

We also created the pxelinux.cfg directory, which is where pxelinux searches for configuration files by default. Because we don't want to discriminate between different host MACs, we then create the default configuration.

<pre><code># vim "$root/boot/pxelinux.cfg/default"

default linux

label linux
kernel vmlinuz-linux
append initrd=initramfs-linux.img ip=:::::eth0:dhcp nfsroot=10.0.0.1:/
</code></pre>

NFSv3 mountpoints are relative to the root of the server, not fsid=0. If you're using NFSv3, you'll need to pass 10.0.0.1:/srv/arch to nfsroot.

Or if you are using NBD, use the following append line:

<pre><code>append ro initrd=initramfs-linux.img ip=:::::eth0:dhcp nbd_host=10.0.0.1 nbd_name=arch root=/dev/nbd0
</code></pre>

Note: You will need to change nbd_host and/or nfsroot, respectively, to match your network configuration (the address of the NFS/NBD server)

The pxelinux configuration syntax identical to syslinux; refer to the upstream documentation for more information.

The kernel and initramfs will be transferred via TFTP, so the paths to those are going to be relative to the TFTP root. Otherwise, the root filesystem is going to be the NFS mount itself, so those are relative to the root of the NFS server.

<pre><code># vim "$root/etc/fstab"

/dev/nbd0  /  btrfs  rw,noatime,discard,compress=lzo  0 0
</code></pre>

<h2>Program state directories</h2>

You could mount /var/log, for example, as tmpfs so that logs from multiple hosts don't mix unpredictably, and do the same with /var/spool/cups, so the 20 instances of cups using the same spool don't fight with each other and make 1,498 print jobs and eat an entire ream of paper (or worse: toner cartridge) overnight.

<pre><code># vim "$root/etc/fstab"
tmpfs   /var/log        tmpfs     nodev,nosuid    0 0
tmpfs   /var/spool/cups tmpfs     nodev,nosuid    0 0
</code></pre>

It would be best to configure software that has some sort of state/database to use unique state/database storage directories for each host. If you wanted to run puppet , for example, you could simply use the %H specifier in the puppet unit file:

<pre><code># vim "$root/etc/systemd/system/puppetagent.service"
[Unit]
Description=Puppet agent
Wants=basic.target
After=basic.target network.target

[Service]
Type=forking
PIDFile=/run/puppet/agent.pid
ExecStartPre=/usr/bin/install -d -o puppet -m 755 /run/puppet
ExecStart=/usr/bin/puppet agent --vardir=/var/lib/puppet-%H --ssldir=/etc/puppet/ssl-%H

[Install]
WantedBy=multi-user.target
</code></pre>

Puppet-agent creates vardir and ssldir if they do not exist.

If neither of these approaches are appropriate, the last sane option would be to create a systemd generator that creates a mount unit specific to the current host (specifiers are not allowed in mount units, unfortunately).

