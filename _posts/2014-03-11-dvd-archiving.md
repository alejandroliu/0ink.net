---
ID: "811"
post_author: "2"
post_date: "2014-03-11 19:15:12"
post_date_gmt: "2014-03-11 19:15:12"
post_title: DVD archiving
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: dvd-archiving
to_ping: ""
pinged: ""
post_modified: "2014-03-11 19:15:12"
post_modified_gmt: "2014-03-11 19:15:12"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=811
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: DVD archiving
...
---

This is my simple procedure for backing up my DVD movies:

Examine the DVD:

<pre><code>dvdbackup -i /dev/sr0 -I
</code></pre>

Create a full backup:

<pre><code>dvdbackup -i /dev/dvd -o ~ -M
</code></pre>

Creating an ISO:

<pre><code>mkisofs -dvd-video -udf -o ~/dvd.iso ~/movie_name
</code></pre>

Testing the newly created ISO:

<pre><code>mplayer dvd:// -dvd-device ~/dvd.iso
</code></pre>

