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
---

This post is just a simple hints-tips to get something going with FirewallD without going into too much detail.

1.  Checking if you are using **firewalld**:
    *   firewall-cmd --state
2.  Check your zones (needed later when opening ports):
    *   firewall-cmd --get-default-zone
    *   firewall-cmd --get-active-zones
3.  Checking what is active:
    *   firewall-cmd --zone=public --list-all
4.  Opening services:
    *   firewall-cmd --zone=public --add-service=http Or alternatively:
    *   firewall-cmd --permanent --zone=public --add-service=http
    *   firewall-cmd --reload Services are defined in /usr/lib/firewalld/services and /etc/firewalld/services.
5.  Opening ports:
    *   firewall-cmd --permanent --zone=public --add-port=443/tcp
    *   firewall-cmd --reload

