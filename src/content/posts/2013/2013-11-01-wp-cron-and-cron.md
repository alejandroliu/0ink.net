---
ID: "720"
post_author: "2"
post_date: "2013-11-01 14:49:34"
post_date_gmt: "2013-11-01 14:49:34"
post_title: wp-cron and cron
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: wp-cron-and-cron
to_ping: ""
pinged: ""
post_modified: "2013-11-01 14:49:34"
post_modified_gmt: "2013-11-01 14:49:34"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=720
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: wp-cron and cron
tags: wordpress
---

Normal WordPress operation has a cron like functionality that runs scheduled tasks as users visit the blog.

It is possible to replace this with a standalone cron (like UNIX cron).

To disable the "webcron" (i.e. trigerring tasks as URLs are visited) add to your <code>wp-config.php</code> the following:

<pre><code> define('DISABLE_WP_CRON', true);
</code></pre>

Then call this from cron:

<pre><code> curl http://example.com/wp-cron.php
</code></pre>

Optionally you could call <code>wp-cron.php</code> using the <code>php-cli</code> executable.

