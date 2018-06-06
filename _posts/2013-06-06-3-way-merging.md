---
ID: "499"
post_author: "2"
post_date: "2013-06-06 07:01:40"
post_date_gmt: "2013-06-06 07:01:40"
post_title: Upgrading pacman config files
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: 3-way-merging
to_ping: ""
pinged: ""
post_modified: "2013-06-06 07:01:40"
post_modified_gmt: "2013-06-06 07:01:40"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=499
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Upgrading pacman config files
...
---

So when upgrading software packages sometimes you need to merge changes.  My recipe in <strong>archlinux</strong> is as follows:

<ol>
    <li>Look for <strong>*.pacnew</strong> files.</li>
    <li>Retrieve the original version (from /var/cache/pacman) from the old source package.</li>
    <li>Use a 3 way merge tool between old version, current file and the pacnew file.</li>
</ol>

These are my options for merging:

<ul>
    <li>diff3 -m : Merges the changes into a single file (Use -m option)</li>
    <li><a title="diffuse" href="http://diffuse.sourceforge.net/">diffuse</a></li>
    <li><a title="meld merge" href="http://meldmerge.org/">meld</a></li>
</ul>

