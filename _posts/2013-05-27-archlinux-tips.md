---
ID: "379"
post_author: "2"
post_date: "2013-05-27 12:08:26"
post_date_gmt: "2013-05-27 12:08:26"
post_title: ArchLinux tips
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: archlinux-tips
to_ping: ""
pinged: ""
post_modified: "2013-05-27 12:08:26"
post_modified_gmt: "2013-05-27 12:08:26"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=379
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: ArchLinux tips

---

<h1>Custom Repos and Packages</h1>

In the repo directory, put all the packages in there.

<pre><code>repo-add ./custom.db.tar.gz ./*
</code></pre>

Add to <code>pacman.conf</code>:

<pre><code>[custom]
SigLevel = [Package|Databse]Never|Optional|Required
Server = path-to-repo
</code></pre>

See also <code>repo-remove</code>.

A package database is a tar file, optionally compressed. Valid extensions are <code>.db</code> or <code>.files</code> followed by an archive extension of <code>.tar</code>, <code>.tar.gz</code>, <code>.tar.bz2</code>, <code>.tar.xz</code>, or <code>.tar.Z</code>. The file does not need to exist, but all parent directories must exist.

?Can we create a <code>rpmgot.php</code> hack?

<h1>Safe automatic pacman upgrades</h1>

<ul>
<li><a href="https://bbs.archlinux.org/viewtopic.php?id=66822">safepac</a> : This is an approach for
automating pacman upgrades yet catching <em>problematic</em> updates before hand.</li>
</ul>

<h1>Building packages</h1>

requires: @base-devel, abs, fakeroot

<pre><code>makepkg -s 
</code></pre>

or

<pre><code>makeworld ?
</code></pre>

<h1>Working with the serial console</h1>

Configure your Arch Linux machine so you can connect to it via the serial console port (com port). This will enable you to administer the machine even if it has no keyboard, mouse, monitor, or network attached to it (a headless server).

<h2>Configuration</h2>

Add this to the bootloader kernel line:

<pre><code>console=tty0 console=ttyS0,9600
</code></pre>

From systemd:

<pre><code>systemctl enable getty@ttyS0.service 
</code></pre>

<h1>Installing Arch Linux using the serial console</h1>

<ol>
<li>Boot the target machine using the Arch Linux installation CD.</li>
<li>When the bootloader appears, select "Boot Arch Linux ()" and press tab to edit</li>
<li>Append console=ttyS0 and press enter</li>
<li>Systemd should now detect ttyS0 and spawn a serial getty on it, allowing you to proceed as usual</li>
</ol>

Note: After setup is complete, the console settings will not be saved on the target machine; in order to avoid having to connect a keyboard and monitor, configure console access on the target machine before rebooting.

<hr />

<h1>Identifying files not owned by any package</h1>

<pre><code>pacman-disowned

#!/bin/sh

tmp=${TMPDIR-/tmp}/pacman-disowned-$UID-$$
db=$tmp/db
fs=$tmp/fs

mkdir "$tmp"
trap 'rm -rf "$tmp"' EXIT

pacman -Qlq | sort -u &gt; "$db"

find /bin /etc /sbin /usr 
  ! -name lost+found 
  ( -type d -printf '%p/n' -o -print ) | sort &gt; "$fs"

comm -23 "$fs" "$db"
</code></pre>

<h1>Pacman one liners</h1>

<ul>
<li>Remove packages and its dependancies.

pacman -Rs ...</p></li>
<li><p>List explicitly installed packages

pacman -Qeq</p></li>
<li><p>List orphans

pacman -Qtdq</p></li>
<li><p>Remove everything but base group

pacman -Rs $(comm -23 &lt;(pacman -Qeq|sort) &lt;((for i in $(pacman -Qqg base); do pactree -ul $i; done)|sort -u|cut -d ' ' -f 1))</p></li>
<li><p>Listing changed configuraiton files

pacman -Qii | awk '/^MODIFIED/ {print $2}'</p></li>
<li><p>Download a package without installing it

pacman -Sw package_name</p></li>
<li><p>Manage pacman cache

<p>paccache -h</p></li>
</ul>

