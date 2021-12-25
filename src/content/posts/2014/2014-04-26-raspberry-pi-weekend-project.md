---
ID: "61"
post_author: "2"
post_date: "2014-04-26 06:01:22"
post_date_gmt: "2014-04-26 06:01:22"
post_title: Raspberry Pi Weekend project
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: raspberry-pi-weekend-project
to_ping: ""
pinged: ""
post_modified: "2016-10-28 15:17:07"
post_modified_gmt: "2016-10-28 15:17:07"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=61
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Raspberry Pi Weekend project
tags: computer, device, filesystem, linux, power, raspberry, scripts, software
---

So finally took the time to try out a Raspberry Pi. For this weekend project wanted to do something _relatively_ simple.
Essentially, I wanted to recreate/enhance the functionality of a
[TL-WR702N](http://www.tp-link.com/en/products/details/?model=TL-WR702N).

![tl-wr702n-01]({static}/images/2014/TL-WR720N-01.jpg)

The TL-WR702N Nano Router is a neat device but being closed, can not be customized to what I wanted. It can be used in
the following modes:

*   AP
*   Client
*   Repeater
*   Router
*   Bridge

Specifically I was interested in the bridge mode. However, rather
than bridging from one SSID to another SSID, I wanted to _route/nat_
between the two. So in theory, should be simple to implement (as the
hardware should have all the necessary components) but not allowed by
the software.

Enter the Raspberry Pi.
=======================

So the Pi, is a mini computer that can be loaded with any software you want. The B-model, has a built-in Ethernet and USB ports to plug-in _two_ WIFI adaptors. For this functionality I am using the following:

*   Raspberry-Pi Model-B
    ![Raspberry Pi](https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Raspberry_Pi_B%2B_top.jpg/300px-Raspberry_Pi_B%2B_top.jpg)
*   WIFI stick (2 units)
    ![WIFI]({static}/images/2014/993655_LB_00_FB.EPS_250.jpg)

For the software I am using:

*   [Raspberry Pi buildroot](https://github.com/gamaral/rpi-buildroot)
*   [hostapd-rtl8192cu from Realtek](http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=1&PNid=21&PFid=48&Level=5&Conn=4&DownTypeID=3&GetDown=false&Downloads=true)
    You need to get the RTL8188CUS package for Linux.

So you need two WIFI adaptors, as one will not work as master and slave at the same time. Essentially, one WIFI interface will act as the client WIFI station. The other WIFI interface acts as a WIFI hotspot. I chose to use `buildroot` instead of a normal Linux distro like [Raspbian](http://www.raspbian.org/) or [Arch Linux Arm](http://archlinuxarm.org/platforms/armv6/raspberry-pi) because I wanted to run it as an embedded system. Normal Linux distro's are supposed to be properly _shutdown_ and would complain when you simply yank the power cord. The `buildroot` image I have is customized so that the file system is always mounted read-only. It will switch to read-write only to write persistent data and then switch back to read-only. The normal `hostapd` that comes with `buildroot` is the normal open source project and does not come with the `rtl8192cu` driver. You need to download and build the `Realtek` version. For this to work, I did the following:

1.  Create a start-up scripts that set the whole thing up.

    *   sets-up the filesystem
    *   starts `syslog`, `sshd`, `rngd`
    *   sets-up `eth0` and `wlan0` to be configured by `ifplugd`
    *   starts `wpa_supplicant` on `wlan0`
    *   starts `httpd`
    *   start and configure `wlan1` as an Access Point.
    *   start and configure `dnsmasq` for DNS and DHCP.
2.  Wrote a small web UI to configure the WIFI client.

All this stuff can be found in [github](https://github.com/alejandroliu/harpy).
