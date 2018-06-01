---
ID: "924"
post_author: "2"
post_date: "2015-09-21 06:36:57"
post_date_gmt: "2015-09-21 06:36:57"
post_title: Centos7/RHEL7 FirewallD -- the least you need to know
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: centos7rhel7-firewalld-the-least-you-need-to-know
to_ping: ""
pinged: ""
post_modified: "2015-09-21 06:36:57"
post_modified_gmt: "2015-09-21 06:36:57"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=924
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Centos7/RHEL7 FirewallD -- the least you need to know
...
---

This post is just a simple hints-tips to get something going with FirewallD without going into too much detail.

<ol>
<li>Checking if you are using <strong>firewalld</strong>:

<ul>
<li>firewall-cmd --state</li>
</ul></li>
<li>Check your zones (needed later when opening ports):

<ul>
<li>firewall-cmd --get-default-zone</li>
<li>firewall-cmd --get-active-zones</li>
</ul></li>
<li>Checking what is active:

<ul>
<li>firewall-cmd --zone=public --list-all</li>
</ul></li>
<li>Opening services:

<ul>
<li>firewall-cmd --zone=public --add-service=http
Or alternatively:</li>
<li>firewall-cmd --permanent --zone=public --add-service=http</li>
<li>firewall-cmd --reload
Services are defined in /usr/lib/firewalld/services and /etc/firewalld/services.</li>
</ul></li>
<li>Opening ports:

<ul>
<li>firewall-cmd --permanent --zone=public --add-port=443/tcp</li>
<li>firewall-cmd --reload</li>
</ul></li>
</ol>
