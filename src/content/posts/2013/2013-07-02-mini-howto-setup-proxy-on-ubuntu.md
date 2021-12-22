---
ID: "614"
post_author: "2"
post_date: "2013-07-02 07:43:24"
post_date_gmt: "2013-07-02 07:43:24"
post_title: 'Mini-Howto: Setup proxy on Ubuntu'
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: mini-howto-setup-proxy-on-ubuntu
to_ping: ""
pinged: ""
post_modified: "2016-11-14 13:09:24"
post_modified_gmt: "2016-11-14 13:09:24"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=614
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: 'Mini-Howto: Setup proxy on Ubuntu'
date: 2013-07-02
tags: address, browser, cloud, config, editor, linux, proxy, setup, ubuntu
revised: 2021-12-22
---

A quick and dirty mini-howto to setup a proxy on Ubuntu.
This is meant mostly for doing quick setup of a proxy
on a cloud environment.

![logo-ubuntu_su-orange-hex](/images/2013/logo-ubuntu_su-orange-hex.jpg)


1.  Install Squid with the following command at the Linux command prompt:  
    `sudo apt-get install squid`
2.  Edit the Squid config file in `/etc/squid` adding these lines:  
    `http_access allow local_net`  
    `acl local_net src 10.10.0.0/255.255.0.0`
3.  Save the file, exit the editor and restart Squid. You are now ready to configure your browser to use the proxy server.
4.  Click "Tools," "Options," "Advanced," "Network" and "Settings" in Firefox, which is the normal Ubuntu Linux browser. Select "Manual Proxy Configuration," enter the IP address of your proxy server, enter port 3128 in the Port field and then click "OK."

References:

*   [http://science.opposingviews.com/set-up-secure-proxy-server-ubuntu-linux-23184.html](http://science.opposingviews.com/set-up-secure-proxy-server-ubuntu-linux-23184.html) by Alan Hughes
