---
ID: "1002"
post_author: "2"
post_date: "2016-11-14 13:25:39"
post_date_gmt: "2016-11-14 13:25:39"
post_title: Building chroots with yum
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: building-chroots-with-yum
to_ping: ""
pinged: ""
post_modified: "2016-11-14 13:26:18"
post_modified_gmt: "2016-11-14 13:26:18"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1002
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Building chroots with yum
...
---


Building CHROOTs with Yum in a single command:

    yum --releasever=7 --installroot=/chroot/jail2 -y install httpd

Will install httpd with all its dependancies.  If you are on x86_64 and want a 32 bit chroot:

    setarch i386 yum --releasever=6 --installroot=/chroot/jail32 -y install httpd



