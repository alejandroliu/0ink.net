---
ID: "714"
post_author: "2"
post_date: "2013-10-31 19:43:11"
post_date_gmt: "2013-10-31 19:43:11"
post_title: Using wget with given IP/vhost
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: using-wget-with-given-ipvhost
to_ping: ""
pinged: ""
post_modified: "2013-10-31 19:43:11"
post_modified_gmt: "2013-10-31 19:43:11"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=714
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Using wget with given IP/vhost
---

This is one neat trick.  For vhosts you can connect with an IP yet provide the right host name with the following:

<pre><code> wget http://1.1.1.1/  --header 'Host: www.example.com'
</code></pre>

