---
ID: "9"
post_author: "2"
post_date: "2013-07-01 10:14:48"
post_date_gmt: "2013-07-01 10:14:48"
post_title: Using CloudFlare
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: using-cloudflare
to_ping: ""
pinged: ""
post_modified: "2016-10-28 15:26:29"
post_modified_gmt: "2016-10-28 15:26:29"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=9
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Using CloudFlare
---

So I have signed up `0ink.net` to use the [CloudFlare](http://www.cloudflare.com "CloudFlare") service.

![CFLogo]({{ site.url }}/images/2013/cf-logo-v-rgb.png)

[CloudFlare](http://www.cloudflare.com "CloudFlare") is a reverse proxy service that is supposed to speed up and improve web server security.

This is done by:

*   globally distributed reverse proxy cache [network](http://www.cloudflare.com/system-status.html "Cloudflare status")
*   filters incoming request for attacks
*   optimize content (i.e. compressing, removing redundnat text, etc).
*   improving retrieving of web pages that have multiple components.

For it to work they need to take over your DNS service. That means that your DNS records resolve to [CloudFlare](http://www.cloudflare.com "CloudFlare") servers. So when editing your DNS records, the [CloudFlare](http://www.cloudflare.com "CloudFlare") DNS editor has an extra settings that allows you to control if that DNS entry would use the [CloudFlare](http://www.cloudflare.com "CloudFlare") network or not.

So if you want to be able to access your web server (i.e. www) for `ftp` or `ssh`, then you need  
to create an additinional CNAME record that points to the web server but set to by-pass the [CloudFlare](http://www.cloudflare.com "CloudFlare") network.

Some tips on what to do after install cloudflare can be found [here](http://blog.cloudflare.com/top-tips-after-installing-cloudflare "Tips on using Cloudflare").

This is handy command to test if your web-server is having problems but not [CloudFlare](http://www.cloudflare.com "CloudFlare")

     curl -v -A firefox/4.0 -H 'Host: yourdomain.com' YourServerIP
