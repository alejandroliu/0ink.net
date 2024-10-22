---
title: Remote Bridging
date: "2023-08-27"
author: alex
ID: "381"
post_author: "2"
post_date: "2013-05-27 12:15:42"
post_date_gmt: "2013-05-27 12:15:42"
post_title: Remote Bridging
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: remote-bridging
to_ping: ""
pinged: ""
post_modified: "2013-05-27 12:15:42"
post_modified_gmt: "2013-05-27 12:15:42"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=381
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
tags: address, computer, config, configuration, device, domain, encryption, idea,
  management, network, password, remote, setup, software, speed
---
Sometimes we need to connect two or more geographically distributed ethernet networks to one broadcast domain. There can be two different office networks of some company which uses smb protocol partially based on broadcast network messages. Another example of such situation is computer cafes: a couple of computer cafes can provide to users more convinient environment forr playing multiplayer computer games without dedicated servers. Both sample networks in this article need to have one *nix server for bridging. Our networks can be connected by any possible hardware that provides IP connection between them.

Connecting Two Remote Local Networks With Transparent Bridging Technique
========================================================================


Short description
-----------------

In described configuration we are connecting two remote LANs to make them appearing as one network with 192.168.1.0/24 address space (however physically, presense of bridges in network configuration is not affecting IP protocol and is fully transparent for it, so you can freely select any address space). Both of the bridging servers has two network interfaces: one (as eth0 in our example) connested to the LAN, and second (eth1) is being used as transport to connect networks. When ethernet tunnel between gateways in both networks will be bringed up we will connect tunnel interfaces with appropriate LAN interfaces with bridge interfaces. Schematically this configuration can be following:

```lineart
              +-------+                       +-------+
              |  br0  |                       |  br0  |
              +-------+                       +-------+
               |     |                         |     |
    Network 1  |     |                         |     |   Network 2
    ----------eth0  tap0---eth1........eth1---tap0  eth0---------------
```


Setting Up Bridging Servers
===========================

_Notice: This article describes Debian GNU/Linux servers setup. If you are using another distribution, there can be some differences in network configuration and package management, but the main idea of described actions will be the same._ First of all, we need to check if tun and bridge modules is not included in current kernel. If they are not includen, we need to rebuild kernel with CONFIG\_TUN and CONFIG\_BRIDGE options. Next, we need to create tunnel device file for our tunnel:

    # cd /dev
    # ./MAKEDEV tun
    # mkdir misc
    # ln -s /dev/net /dev/misc/net
    

_Notice: Last command is needed to make vtun work, because authors build for debian is looking for tunnel device driver at /dev/misc/net/tun._ To create ethernet tunnel between bridging servers we will use **vtun** software. When `vtun` will be installed, we will need to select one of the bridging servers as master and second server will be slave and appropriately change vtund-start.conf and vtund.conf file in /etc/ on buth servers. Complete config files for master is following.

    /etc/vtund-start.conf
    ----cut-here------------------------------------
    --server-- 5000
    ----cut-here------------------------------------
    
    /etc/vtund.conf
    ----cut-here------------------------------------
    options {
        port 5000;            # Listen on this port.
    
        # Syslog facility
        syslog        daemon;
    
        # Path to various programs
        ifconfig      /sbin/ifconfig;
        route         /sbin/route;
        firewall      /sbin/iptables;
        ip            /sbin/ip;
    }
    
    default {
        compress no;
        encrypt no;
        speed 0;
    }
    
    rembridge {
        passwd Pa$$Wd;
        type ether;
        proto udp;
        keepalive yes;
        compress no;
        encrypt yes;
    
        up {
            # Connection is Up
            ifconfig "%% up";
            program "brctl addif br0 %%";
        };
    
        down {
            # Connection is Down
            ifconfig "%% down";
        };
    }
    ----cut-here------------------------------------
    

Slave server config files is following:

    /etc/vtund-start.conf
    ----cut-here------------------------------------
    rembridge 10.1.1.1 -p
    ----cut-here------------------------------------
    

_Notice: In this example 10.1.1.1 is transport address of master server._

    /etc/vtund.conf
    ----cut-here------------------------------------
    options {
      # Path to various programs
      ifconfig      /sbin/ifconfig;
      route         /sbin/route;
      firewall      /sbin/iptables;
    }
    
    korsar {
      pass  Pa$$Wd;         # Password
      type  ether;          # Ethernet tunnel
      up {
            # Connection is Up
            ifconfig "%% up";
            program "brctl addif br0 %%"
      };
      down {
            # Connection is Down
            ifconfig "%% down";
      };
    }
    ----cut-here------------------------------------
    

To bring up bridge between LAN ethernet interface and our newly created tunnel interface we need to create bridge interface. To complete this task we will add br0 interface description to /etc/network/interfaces file:

    auto br0
    iface br0 inet static
        address 192.168.1.199
        netmask 255.255.255.0
        bridge_ports eth0
    

_Notice: IP-addresses on both sides of our bridge must be unique in both networks. eth0 is LAN interface._ Now, we need to bring this interface up:

    # ifup br0
    

When br0 interface will be created, we will be able to start vtun. # /etc/init.d/vtund restart If everything was done correctly, we will see following results on both sersers (br0 and tap0 interfaces):

    # ifconfig tap0
    tap0  Link encap:Ethernet  HWaddr 00:FF:B2:91:CA:DE
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:701818 errors:0 dropped:0 overruns:0 frame:0
          TX packets:405939 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:975889241 (930.6 MiB)  TX bytes:44704104 (42.6 MiB)
    
    # ifconfig br0
    br0   Link encap:Ethernet  HWaddr 00:02:44:2A:03:30
          inet addr:192.168.1.199  Bcast:192.168.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2660 errors:0 dropped:0 overruns:0 frame:0
          TX packets:42 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:239368 (233.7 KiB)  TX bytes:2338 (2.2 KiB)
    
    #
    

If we need to see current state of bridge interface, we can use brctl tool:

    # brctl show br0
    bridge name     bridge id               STP enabled     interfaces
    br0             8000.0002442a0330       no              eth0
                                                            tap0
    #
    

When all of described steps will be completed, our computers in both networks will be able to communicate with each other. IP addresses on bridge interfaces can be used for troubleshooting network connection. And last, if you need, you can turn on compression or enrtyption of data within created tunnel.
