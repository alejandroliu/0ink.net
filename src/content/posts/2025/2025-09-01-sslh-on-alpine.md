---
title: Using SSLH on Alpine Linux
date: "2025-01-21"
author: alex
tags: configuration, address, proxy, feature, cloud, database, directory, alpine,
  device
---
![icon]({static}/images/2025/sslh-icon.png)

Install sslh

```bash
apk add sslh
```

Configure sslh startup:

```bash
# /etc/conf.d/sslh
# configuration for /etc/init.d/sslh
#
# The sslh binary to run; one of:
#
# fork    Forks a new process for each incoming connection. It is well-tested
#         and very reliable, but incurs the overhead of many processes.
# select  Uses only one thread, which monitors all connections at once. It is
#         more recent and less tested, but has smaller overhead per connection.
#mode="fork"
mode="select"
# Path of the configuration file.
#cfgfile="/etc/sslh.conf"
# Additional options to pass to the sslh daemon. See sslh(1) man page.
#command_args=""
# Uncomment to run the sslh daemon under process supervisor.
```

We set mode to `select` as this is most efficient.  For package versions before
`2.1.2-r1` the default **init** script will fail to start when `fork` mode is
selected.

Create sslh configuration.  For more configuration examples see [example.cfg][cfg].

```yaml
# /etc/sslh.conf

timeout: 2;
# Timeout before forwarding the connection to the timeout protocol
# The default is 2s.  If using OpenVPN, this needs to be increased to
# 5s for OpenVPN to work reliably.

transparent: true;
# Make SSLH act as a transparent proxy.  See later for more
# configuration steps.

user: "nobody";
# Run process as the given user.  Note that transparent mode
# will not work if user is not root.

numeric: true;
# Do not attempt to resolve hostnames: logs will contain IP addresses.
# This is mostly useful if the system's DNS is slow and running the sslh-select variant,
# as DNS requests will hang all connections.


listen:
(
  { host: "0.0.0.0"; port: "443"; },
  { host: "::"; port: "443"; }
);
# List of listening address and ports.  This is probably enough, but sslh
# can also listen on UDP sockets, IPv6 addresses, and UNIX sockets.

protocols:
(
  { name: "ssh"; host: "localhost"; port: "22";
    fork: true;},
  { name: "tls"; host: "localhost"; port: "8443";
  	sni_hostnames: [ "app1.example.com", "app2.example.com" ];
    log_level: 0;  tfo_ok: true },
  { name: "tls"; host: "localhost"; port: "9443";
  	sni_hostnames: [ "app3.example.com", "app4.example.com" ];
    log_level: 0;  tfo_ok: true },
  { name: "tls"; host: "localhost"; port: "7443";
    log_level: 0; tfo_ok: true; },
  { name: "tls"; host: "localhost"; port: "443";
    log_level: 0; tfo_ok: true; },  
);
# Connections that match the given protocol will be forwarded to host:port.
# For TLS, you can match based on sni_hostnames from the TLS handshake.
# Options:
# log_level: 0 turn off logging
#            1 logs every incoming request.  Hor https, makes sense to turn off logging
# fork: For sslh-select, will fork a new process for the connection
# tfo_ok: Enable TCP fast open.


# on-timeout: "ssh";
# By default it will connect to the "ssh" specification on time-out.  If
# you want to change the time out target, create a "timeout" protocol
# and set on-timeout: to "timeout".  The default to connect to "ssh"
# on timeout is a sane default.

# Logging configuration
# Value: 1: stdout; 2: syslog; 3: stdout+syslog; 4: logfile; ...; 7: all
verbose-config: 0; #  print configuration at startup
verbose-config-error: 3;  # print configuration errors
verbose-connections: 3; # trace established incoming address to forward address
verbose-connections-error: 3; # connection errors
verbose-connections-try: 3; # connection attempts towards targets
verbose-fd: 0; # file descriptor activity, open/close/whatnot
verbose-packets: 0; # hexdump packets on which probing is done
verbose-probe-info: 3; # what's happening during the probe process
verbose-probe-error: 3; # failures and problems during probing
verbose-system-error: 3; # system call problem, i.e.  malloc, fork, failing
verbose-int-error: 3; # internal errors, the kind that should never happen```
```

For https traffic, it is advisable to enable [tfo_ok][tfo] as it enables
[TCP Fast Open][tfo] feature, which reduces the connection time by reducing
round-trips.

For trasnparent proxying, I have tested two scenarios.

1. One host running [sslh][sslh] *and* sshd and web server.
   ```lineart
                        .-.               .--------.
                     .-+   |             | Server   |
   +--------+    .--+       '--.         | - sslh   |
   | client |<-->|   Internet   |<------>| - ssh    |
   +--------+    '-------------'         | - nginx  |
                                          '--------'
   ```
2. Two hosts, host A running [sslh][sslh], host B running sshd and web server.
   Default route of host B points to host A.
   ```lineart
                        .-.               .-------.        .-------.
                     .-+   |             |         |      |         |
   +--------+    .--+       '--.         | Host A  |      | Host B  |
   | client |<-->|   Internet   |<------>| - sslh  |<---->| - ssh   |
   +--------+    '-------------'         |         |      | - nginx |
                                          '-------'        '-------'
   ```

These an additional scenario are described in the [sslh documentation][examples].

# Single host transparent proxy

In this example, IP address `203.0.113.23` is being used.  This is for a a host
with a single external IP interface `eth0`.

Modify OpenSSh configuration:

```text
# Restrict interfaces that sshd will bind to
ListenAddress 0.0.0.0:22			# Direct access
ListenAddress 203.0.113.23:2201		# Access via sslh
```

Modify nginx configuration:

```text
listen 203.0.113.23:4433 ssl http2;
```

By using dedicated ports for [sslh][sslh] traffic, we make it simpler
to identify the transparently proxied traffic.


Create a netfilter table ( `/etc/nftables.d/sslh.nft` ):

```text

#!/usr/sbin/nft -f

# Use ip as we want to configure sslh only for IPV4
table ip sslh {
        chain output {
                type route  hook output  priority -150;
                oif eth0  tcp sport { 2201, 4433 }  counter  mark set 0x4155;
        }
}
```

Since we were using dedicated ports earlier, we can use these simple netfilter
rules to identify the traffic that is being proxied. We then mark with `0x4155`
so that it can be directed to the loopback interface.

	
In the `/etc/network/interfaces` configuration:
```text
iface eth0 inet static
  address 203.0.113.23
  netmask 255.255.255.0
  up   ip rule add fwmark 0x4155 lookup 100
  down ip rule del fwmark 0x4155 lookup 100
  up   ip route add local 0.0.0.0/0 dev lo table 100
  down ip route del local 0.0.0.0/0 dev lo table 100
  
```

This grabs the traffic marked with `0x4155` by the netfilter rules and routes
them to the loopback so [sslh][sslh] can pick it up.

See [sslh installation][sslhdeb] on how to install on a debian system.

# Two host transparent proxy

I find this configuration simpler/nicer as does not use nftables rules.
You need to add the following routing rules somewhere.  I am using a file in
`/etc/local.d` directory for [Alpine Linux][alpine].
Other options are the startscript of sslh, the `/etc/conf.d/sslh` file, the
configuration of the outgoing interface.  The lines needed are:

```bash
ip rule add from $HOST_B_ADDRESS/32 table 100
ip route add local 0.0.0.0/0 dev lo table 100
```

If you are forwarding connections to more hosts, you need to add those rules here.

It is important to note that the `$HOST_B_ADDRESS` mentioned needs to be an IP 
address dedicated to [sslh][sslh] traffic.  Otherwise normal traffic for host
B would also be redirected to the host A loopback device.

![mux]({static}/images/2025/sslh-mux.png)


  [cfg]: https://github.com/yrutschle/sslh/blob/master/example.cfg
  [tfo]: https://en.wikipedia.org/wiki/TCP_Fast_Open
  [sslh]: https://www.rutschle.net/tech/sslh/README.html
  [examples]: https://github.com/yrutschle/sslh/blob/master/doc/scenarios-for-simple-transparent-proxy.md
  [alpine]: https://alpinelinux.org/
  [sslhdeb]: https://wiki.meurisse.org/wiki/sslh