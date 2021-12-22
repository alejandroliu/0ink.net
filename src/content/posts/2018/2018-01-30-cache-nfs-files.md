---
title: using cachefiles on an Linux NFS share
date: 2018-01-30
tags: centos, configuration, filesystem, information, installation, linux, network, partition, remote, service, storage, sudo, ubuntu
revised: 2021-12-22
---


If you often mount and access a remote NFS share on your system, you
will probably want to know how to improve NFS file access performance.
One possibility is using file caching. In Linux, there is a caching
filesystem called FS-Cache which enables file caching for network file
systems such as NFS. FS-Cache is built into the Linux kernel 2.6.30
and higher.

In order for FS-Cache to operate, it needs cache back-end which
provides actual storage for caching. One such cache back-end is
cachefiles. Therefore, once you set up cachefiles, it will
automatically enable file caching for NFS shares.

In this tutorial, I will describe **how to enable local file caching for
NFS shares** by using cachefiles.

# Requirements for Setting Up CacheFiles

One requirement for setting up cachefiles is that local filesystem
support user-defined extended file attributes (i.e., xattr), because
cachefiles use xattr to store extra information for cache maintenance.

If your local filesystem is ext4-type, you don't need to worry about
this since xattr is enabled in ext4 by default.

However, if you are using ext3 filesystem, then you need to mount the
local filesystem with "user_xattr" option. To do so, edit /etc/mtab
to add "user_xattr" mount option to the disk partition that will be
used by cachefiles for file caching. For example, assuming that
`/dev/hda1` is such a partition:

```
/dev/hda1 / ext3 rw,user_xattr  0 0
```

After modifying /etc/fstab, reload it by running:

```
sudo mount -o remount /
```

# Set Up CacheFiles

In order to set up cache back-end using cachefiles, you need to
install `cachefilesd`, a userspace daemon for managing cachefiles.

To install `cachefilesd` on Ubuntu or Debian:

```
sudo apt-get install cachefilesd
```

To install cachefilesd on CentOS, Fedora or RedHat:

```
sudo yum install cachefilesd
sudo chkconfig cachefilesd on
```

After installation, enable cachefilesd by editing its configuration
file as follows.

```
sudo vi /etc/default/cachefilesd

RUN=yes
```

Next, mount a remote NFS share with fsc option:

```
sudo vi /etc/fstab

192.168.1.13:/home/xmodulo /mnt nfs rw,hard,intr,fsc
```

Alternatively, if you mount the remote NFS share from the command line, specify fsc as a command-line option:

```
sudo mount -t nfs 192.168.1.13:/home/xmodulo /mnt -o fsc
```

Finally, restart cachefilesd:

```
sudo service cachefilesd restart
```

At this point, file caching should be enabled for the mounted NFS
share, which means that previously accessed files in the mounted
NFS share will be retrieved from local file cache.

If you want to flush NFS file cache for any reason, simply restart
cachefilesd.

```
sudo service cachefilesd restart
```

Reference: [xmodule.com](http://xmodulo.com/how-to-enable-local-file-caching-for-nfs-share-on-linux.html)
