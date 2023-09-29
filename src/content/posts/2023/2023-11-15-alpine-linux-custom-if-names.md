---
title: Alpine Linux Custom Interface names
tags: alpine, configuration, device, linux, network
---
This article is a copy of [this article](https://wiki.alpinelinux.org/wiki/Custom_network_interface_names)
and  shows how to rename/change name of a network interface.

Alpine Linux uses `busybox` `mdev` to manage devices in `/dev`. `mdev` reads `/etc/mdev.conf`
and according to [mdev documentation](https://git.busybox.net/busybox/plain/docs/mdev.txt) one
can define a command to be executed per device definition.
The command which is going to be used to change network interface name is `nameif`.

## `/etc/mdev.conf` configuration

```
-SUBSYSTEM=net;DEVPATH=.*/net/.*;.*     root:root 600 @/sbin/nameif -s
```

Here we tell `mdev` to call `nameif` for devices found in `/sys/class/net/`.

```
# ls -d -C -1 /sys/class/net/eth*
/sys/class/net/eth1
/sys/class/net/eth2
/sys/class/net/eth3
/sys/class/net/eth4
/sys/class/net/eth5
```

## `nameif` configuration

`nameif` itself reads `/etc/mactab'` by default. Example line for a network interface with
following hwaddr

```
# cat /sys/class/net/eth0/address
90:e2:ba:04:28:c0
```

would be

```
# grep 90:e2:ba:04:28:c0 /etc/mactab 
dmz0 90:e2:ba:04:28:c0
```

## finalization

To use renamed network interface without reboot, just call `nameif` while the network
interface is down.

```
# nameif -s
```

And finally reboot...



