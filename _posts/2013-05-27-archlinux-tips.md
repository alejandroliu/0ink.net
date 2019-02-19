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

A bunch of recipes useful for an ArchLinux system environment.

Mostly around system administration.

# Custom Repos and Packages

In the repo directory, put all the packages in there.

```
repo-add ./custom.db.tar.gz ./*

```

Add to `pacman.conf`:

```
[custom]
SigLevel = [Package|Databse]Never|Optional|Required
Server = path-to-repo

```

See also `repo-remove`. A package database is a tar file, optionally compressed. Valid extensions are `.db` or `.files` followed by an archive extension of `.tar`, `.tar.gz`, `.tar.bz2`, `.tar.xz`, or `.tar.Z`. The file does not need to exist, but all parent directories must exist. ?Can we create a `rpmgot.php` hack?

# Safe automatic pacman upgrades

*   [safepac](https://bbs.archlinux.org/viewtopic.php?id=66822) : This is an approach for automating pacman upgrades yet catching _problematic_ updates before hand.

# Building packages

requires: @base-devel, abs, fakeroot

```
makepkg -s 

```

or

```
makeworld ?

```

# Working with the serial console

Configure your Arch Linux machine so you can connect to it via the serial console port (com port). This will enable you to administer the machine even if it has no keyboard, mouse, monitor, or network attached to it (a headless server).

## Configuration

Add this to the bootloader kernel line:

```
console=tty0 console=ttyS0,9600

```

From systemd:

```
systemctl enable getty@ttyS0.service 

```

# Installing Arch Linux using the serial console

1.  Boot the target machine using the Arch Linux installation CD.
2.  When the bootloader appears, select "Boot Arch Linux ()" and press tab to edit
3.  Append console=ttyS0 and press enter
4.  Systemd should now detect ttyS0 and spawn a serial getty on it, allowing you to proceed as usual

Note: After setup is complete, the console settings will not be saved on the target machine; in order to avoid having to connect a keyboard and monitor, configure console access on the target machine before rebooting.

* * *

# Identifying files not owned by any package

```
pacman-disowned

#!/bin/sh

tmp=${TMPDIR-/tmp}/pacman-disowned-$UID-$$
db=$tmp/db
fs=$tmp/fs

mkdir "$tmp"
trap 'rm -rf "$tmp"' EXIT

pacman -Qlq | sort -u > "$db"

find /bin /etc /sbin /usr 
  ! -name lost+found 
  ( -type d -printf '%p/n' -o -print ) | sort > "$fs"

comm -23 "$fs" "$db"

```

# Pacman one liners

*   Remove packages and its dependancies. pacman -Rs ...
    
*   List explicitly installed packages pacman -Qeq
    
*   List orphans pacman -Qtdq
    
*   Remove everything but base group pacman -Rs $(comm -23 <(pacman -Qeq|sort) <((for i in $(pacman -Qqg base); do pactree -ul $i; done)|sort -u|cut -d ' ' -f 1))
    
*   Listing changed configuraiton files pacman -Qii | awk '/^MODIFIED/ {print $2}'
    
*   Download a package without installing it pacman -Sw package_name
    
*   Manage pacman cache
    
    paccache -h
