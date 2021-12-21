---
ID: "16"
post_author: "2"
post_date: "2013-07-02 20:58:30"
post_date_gmt: "2013-07-02 20:58:30"
post_title: Web Backups
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: web-backups
to_ping: ""
pinged: ""
post_modified: "2016-10-28 15:22:00"
post_modified_gmt: "2016-10-28 15:22:00"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=16
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Web Backups
---

![cfback]({{ site.url}}/images/2013/bb-images.jpg)

As usual with any IT system backups are important. This does not change when using a free shared hosting provider. Because it is free, one would argue it is even more important.

For my wordpress web site I used something called [cli-exporter](https://github.com/Automattic/WordPress-CLI-Exporter). It let's you create "Wordpress" export files from the command line so it can be run from `cron`. This is important because backups _have_ to be automated.

In addition to that, I copy the backup files to an off-site location. I do this by copying files using WebDAV to a storage provider. I did this by writing a simple script and using the PHP library [SabreDAV](http://code.google.com/p/sabredav/wiki/WebDAVClient) which makes writing DAV clients quite easy.

I myself don't mind using other people's Open Source code to do something. I was actually surprised that I was not able to find something that meet my criteria. However, thanks to the power of open source I was able to find something that fit the bill exactly.

To make things more interesting, because I wanted to keep backup files as compressed Zip archives, my backup scripts did not work in one of the web hosts that I was using. They did not have the `zip` extensions enabled. This is surprising considering is quite standard. Luckily I was able to find a pure PHP library [pclzip](http://www.phpconcept.net/pclzip/).
