---
ID: "688"
post_author: "2"
post_date: "2013-10-07 08:18:47"
post_date_gmt: "2013-10-07 08:18:47"
post_title: Enable local file caching for NFS share on Linux
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: enable-local-file-caching-for-nfs-share-on-linux
to_ping: ""
pinged: ""
post_modified: "2013-10-07 08:18:47"
post_modified_gmt: "2013-10-07 08:18:47"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=688
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Enable local file caching for NFS share on Linux
tags: centos, configuration, filesystem, information, installation, linux, network, partition, remote, service, storage, sudo, ubuntu
---

In Linux, there is a caching filesystem called `FS-Cache` which enables
file caching for network file systems such as NFS. `FS-Cache` is built
into the Linux kernel 2.6.30 and higher. In order for `FS-Cache` to
operate, it needs cache back-end which provides actual storage for
caching. One such cache back-end is `cachefiles`. Therefore, once you
set up `cachefiles`, it will automatically enable file caching for NFS shares.

# Requirements

One requirement for setting up `cachefiles` is that local filesystem support user-defined extended file attributes (i.e., `xattr`), because `cachefiles` use `xattr` to store extra information for cache maintenance. If your local filesystem is ext4-type, you don't need to worry about this since `xattr` is enabled in ext4 by default. However, if you are using ext3 filesystem, then you need to mount the local filesystem with "user\_xattr" option. To do so, edit /etc/mtab to add "user\_xattr" mount option to the disk partition that will be used by `cachefiles` for file caching. For example, assuming that /dev/hda1 is such a partition:

* * *

```
/dev/hda1 / ext3 rw,user_xattr  0 0

```

* * *

After modifying /etc/fstab, reload it by running:

```
$ sudo mount -o remount / 

```

# Configure CacheFiles

In order to set up cache back-end using `cachefiles`, you need to install `cachefilesd`, a userspace daemon for managing `cachefiles`. To install `cachefilesd` on Ubuntu or Debian:

```
$ sudo apt-get install cachefilesd

```

To install `cachefilesd` on CentOS, Fedora or RedHat:

```
$ sudo yum install cachefilesd
$ sudo chkconfig cachefilesd on

```

After installation, enable `cachefilesd` by editing its configuration file as follows.

```
$ sudo vi /etc/default/cachefilesd

```

* * *

```
RUN=yes

```

* * *

Next, mount a remote NFS share with `fsc` option:

```
 $ sudo vi /etc/fstab

```

* * *

```
 192.168.1.13:/home/xmodulo /mnt nfs rw,hard,intr,fsc

```

* * *

Alternatively, if you mount the remote NFS share from the command line, specify `fsc` as a command-line option:

```
$ sudo mount -t nfs 192.168.1.13:/home/xmodulo /mnt -o fsc

```

Finally, restart `cachefilesd`:

```
$ sudo service cachefilesd restart

```

At this point, file caching should be enabled for the mounted NFS share, which means that previously accessed files in the mounted NFS share will be retrieved from local file cache. If you want to flush NFS file cache for any reason, simply restart `cachefilesd`.

```
 $ sudo service cachefilesd restart 

```

Source: [xmodule.com](http://xmodulo.com/2013/06/how-to-enable-local-file-caching-for-nfs-share-on-linux.html)
