---
title: Adding static routes in alpine linux
tags: address, alpine, linux
---
There are several ways to do this documented 
in the alpine linux [wiki](https://wiki.alpinelinux.org/wiki/How_to_configure_static_routes).

My preferred way is to configure it in `/etc/network/interfaces`.

For example:

```
auto eth0
iface eth0 inet static
       address 192.168.0.1
       netmask 255.255.255.0
       up ip route add 10.14.0.0/16 via 192.168.0.2
       up ip route add 192.168.100.0/23 via 192.168.0.3
```

Note that you can actually add these lines in a `dhcp` stanza.

The benefit of doing this is that those routes are added when that interface
is brought up.

Also, they are kicked off by the `networking` init.d file.
