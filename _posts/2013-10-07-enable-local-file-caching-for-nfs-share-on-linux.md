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
...
---

In Linux, there is a caching filesystem called <code>FS-Cache</code> which enables file caching for network file systems such as NFS. <code>FS-Cache</code> is built into the Linux kernel 2.6.30 and higher.

In order for <code>FS-Cache</code> to operate, it needs cache back-end which provides actual storage for caching. One such cache back-end is <code>cachefiles</code>. Therefore, once you set up <code>cachefiles</code>, it will automatically enable file caching for NFS shares.

<h1>Requirements</h1>

One requirement for setting up <code>cachefiles</code> is that local filesystem support user-defined extended file attributes (i.e., <code>xattr</code>), because <code>cachefiles</code> use <code>xattr</code> to store extra information for cache maintenance.

If your local filesystem is ext4-type, you don't need to worry about this since <code>xattr</code> is enabled in ext4 by default.

However, if you are using ext3 filesystem, then you need to mount the local filesystem with "user_xattr" option. To do so, edit /etc/mtab to add "user_xattr" mount option to the disk partition that will be used by <code>cachefiles</code> for file caching. For example, assuming that /dev/hda1 is such a partition:

<hr />

<pre><code>/dev/hda1 / ext3 rw,user_xattr  0 0
</code></pre>

<hr />

After modifying /etc/fstab, reload it by running:

<pre><code>$ sudo mount -o remount / 
</code></pre>

<h1>Configure CacheFiles</h1>

In order to set up cache back-end using <code>cachefiles</code>, you need to install <code>cachefilesd</code>, a userspace daemon for managing <code>cachefiles</code>.

To install <code>cachefilesd</code> on Ubuntu or Debian:

<pre><code>$ sudo apt-get install cachefilesd
</code></pre>

To install <code>cachefilesd</code> on CentOS, Fedora or RedHat:

<pre><code>$ sudo yum install cachefilesd
$ sudo chkconfig cachefilesd on
</code></pre>

After installation, enable <code>cachefilesd</code> by editing its configuration file as follows.

<pre><code>$ sudo vi /etc/default/cachefilesd
</code></pre>

<hr />

<pre><code>RUN=yes
</code></pre>

<hr />

Next, mount a remote NFS share with <code>fsc</code> option:

<pre><code> $ sudo vi /etc/fstab
</code></pre>

<hr />

<pre><code> 192.168.1.13:/home/xmodulo /mnt nfs rw,hard,intr,fsc
</code></pre>

<hr />

Alternatively, if you mount the remote NFS share from the command line, specify <code>fsc</code> as a command-line option:

<pre><code>$ sudo mount -t nfs 192.168.1.13:/home/xmodulo /mnt -o fsc
</code></pre>

Finally, restart <code>cachefilesd</code>:

<pre><code>$ sudo service cachefilesd restart
</code></pre>

At this point, file caching should be enabled for the mounted NFS share, which means that previously accessed files in the mounted NFS share will be retrieved from local file cache.

If you want to flush NFS file cache for any reason, simply restart <code>cachefilesd</code>.

<pre><code> $ sudo service cachefilesd restart 
</code></pre>

Source: <a href="http://xmodulo.com/2013/06/how-to-enable-local-file-caching-for-nfs-share-on-linux.html">xmodule.com</a>

