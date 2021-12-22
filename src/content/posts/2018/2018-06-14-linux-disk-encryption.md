---
ID: "1073"
post_author: "2"
post_date: "2017-03-24 10:59:11"
post_date_gmt: "0000-00-00 00:00:00"
post_title: How to encrypt linux partitions
post_excerpt: ""
post_status: draft
comment_status: open
ping_status: open
post_password: ""
post_name: ""
to_ping: ""
pinged: ""
post_modified: "2017-03-24 10:59:11"
post_modified_gmt: "2017-03-24 10:59:11"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1073
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: How to encrypt linux partitions with LUKS
date: 2018-06-14
tags: centos, device, drive, filesystem, linux, partition, privacy, security, sudo, tools, ubuntu
revised: 2021-12-22
---

There are plenty of reasons why people would need to encrypt a
partition. Whether they're rooted it in privacy, security, or
confidentiality, setting up a basic encrypted partition on a Linux
system is fairly easy. This is especially true when using LUKS, since
its functionality is built directly into the kernel.

# Installing Cryptsetup

## Debian/Ubuntu

On both Debian and Ubuntu, the `cryptsetup` utility is easily
available in the repositories. The same should be true for Mint or
any of their other derivatives.

```
$ sudo apt-get install cryptsetup
````

## CentOS/Fedora

Again, the required tools are easily available in both CentOS and
Fedora. These distributions break them down into multiple packages,
but they can still be easily installed using `yum` and `dnf`
respectively.

### CentOS

```
# yum install crypto-utils cryptsetup-luks cryptsetup-luks-devel cryptsetup-luks-libs
```

### Fedora

```
# dnf install crypto-utils cryptsetup cryptsetup-luks
```

## OpenSUSE

OpenSUSE is more like the Debian based distributions, including
everything that you need with `cryptsetup`.

```
# zypper in cryptsetup
```

## Arch Linux

Arch stays true to its "keep it simple" philosophy here as well.

```
# pacman -S cryptsetup
```

## Gentoo

The main concern that Gentoo users should have when installing the
tools necessary for using LUKS is whether or not their kernel has
support. This guide is not going to cover that part, but just be
aware that kernel support is a factor. If your kernel does support
LUKS, you can just emerge the package.

```
# emerge --ask cryptsetup
```

# Setting Up The Partition

*WARNING:* **The following will erase all data on the partition being
used and will make it unrecoverable. Proceed with caution.**
From here on, none of this is distribution specific. It will all work
well with any distribution.The defaults provided are actually quite
good, but they can easily be customized. If you really aren't
comfortable playing with them, don't worry. If you do know what you
want to do, feel free.

The basic options are as follows:

* --cypher:  This determines the cryptographic cypher used on the
  partition.  The default option is aes-xts-plain64
* --key-size: The length of the key used.  The default is 256
* --hash: Chooses the hash algorithm used to derive the key.  The
  default is sha256.
* --time: The time used for passphrase processing.  The default is
  2000 milliseconds.
* --use-random/--use-urandom: Determines the random number generator
  used.  The default is --use-random.

So, a basic command with no options would look like the line below.

```
# cryptsetup luksFormat /dev/sdb1
```

Obviously, you'd want to use the path to whichever partition that
you're encrypting. If you do want to use options, it would look like
the following.

```
# cryptsetup -c aes-xts-plain64 --key-size 512 --hash sha512 --time 5000 --use-urandom /dev/sdb1
```

`Cryptsetup` will ask for a passphrase. Choose one that is both
secure and memorable. If you forget it, your data *will be lost.*
That will probably take a few seconds to complete, but when it's
done, it will have successfully converted your partition into an
encrypted LUKS volume. 

Next, you have to open the volume onto the device mapper. This is the
stage at which you will be prompted for your passphrase. You can
choose the name that you want your partition mapped under. It doesn't
really matter what it is, so just pick something that will be easy to
remember and use.

```
# cryptsetup open /dev/sdb1 encrypted
```

Once the drive is mapped, you'll have to choose a filesystem type for
you partition. Creating that filesystem is the same as it would be on
a regular partition.

```
# mkfs.ext4 /dev/mapper/encrypted
```

The one difference between creating the filesystem on a regular
partition and an encrypted one is that you will use the path to the
mapped name instead of the actual partition location. Wait for the
filesystem to be created. Then, the drive will be ready for use.

# Mounting and Unmounting

Manually mounting and unmounting encrypted partitions is almost the
same as doing so with normal partitions. There is one more step in
each direction, though. First, to manually mount an encrypted
partition, run the command below.

```
# cryptsetup --type luks open /dev/sdb1 encrypted
# mount -t ext4 /dev/mapper/encrypted /place/to/mount
```

Unmounting the partition is the same as a normal one, but you have to
close the mapped device too.

```
# umount /place/to/mount
# cryptsetup close encrypted
```

# Closing

There's plenty more, but when talking about security and encryption,
things run rather deep. This guide provides the basis for encrypting
and using encrypted partitions, which is an important first step that
shouldn't be discounted. There will definitely be more coming in this
area, so be sure to check back, if you're interested in going a bit
deeper.

* * *

Source [linuxconfig](https://linuxconfig.org/basic-guide-to-encrypting-linux-partitions-with-luks)


