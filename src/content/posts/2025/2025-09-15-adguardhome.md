---
title: AdGuard Home
date: "2025-03-12"
author: alex
tags: software, network, feature, windows, linux, raspberry, setup, tools, installation,
  alpine, authentication, proxy, ansible, address, configuration, integration, directory,
  scripts, power, android, domain, browser, settings, password, application
---
[toc]

![icon]({static}/images/2025/adguardhome/adguard_home_logo-white.png)


[AdGuard Home][agh] is a network-wide ads & trackers blocking DNS server.

After set-up, it will cover *all* your home devices, and you don’t need any client-side
software for that.

With the rise of Internet-Of-Things and connected devices, it becomes more and more
important to be able to control your whole network.

It operates as a DNS server that re-routes tracking domains to a “black hole”, thus preventing
your devices from connecting to those servers.

As a network-wide ad-blocker, [AdGuard Home][agh] competes with [Pi-hole][pihole].  Here is a
comparison table between the two:

Feature		| AdGuard Home		| Pi-hole
------------|-------------------|---------
Platform Support	| Windows, macOS, Linux, Raspberry Pi, Docker	| Linux, Raspberry Pi, Docker
DNS-over-HTTPS/TLS	| Built-in support	| Requires additional setup (using third-party tools)
Filtering Rules Syntax	| AdGuard-specific syntax; supports more complex rules	| Standard DNS filtering rules
Web Interface	| Modern, user-friendly interface	| Simple, functional interface
Block Page Customization	| Limited customization	| More customizable block page
Parental Control	| Built-in support for parental control features	| Lacks built-in parental control features
Regular Expressions	| Supports regular expressions in filters	| Supports regular expressions in filters
Automatic Updates	| No built-in automatic updates	| Built-in automatic updates for blocklists and core components
Community Support	| Growing community	| Larger, well-established community

As you can see, there is no clear winner.  Most people would choose [Pi-Hole][pihole]
as it has a larger, more well-established community. I opted for [AdGuard Home][agh]
because it has a simpler installation process due to very minimal dependancies.

I am using [dnsmasq][dnsmasq] for my DNS and DHCP needs.  It is quite flexible and configurable.
There is some things that I am addressing with [AdGuard Home][agh] that I was
never able to address with [dnsmasq][dnsmasq] itself.

- Ad Blocking:  While it is possible to download block lists and add them
  to [dnsmasq][dnsmasq], this has to be done manually and it was difficult
  to keep up to date.
- Reporting and stats: [dnsmasq][dnsmasq] is able to log DNS queries, you
  have to create repots and generate statistics on your own.
- DNS interface: [dnsmasq][dnsmasq] lacks this completely.

[AdGuard Home][agh] does not cover all the functionality that [dnsmasq][dnsmasq] provides
such as:

- tftp for PXE booting
- No DHCP configuration for IPv6 (at least I couldn't find instructions for it)
- CLI integration

At the end, I am using [AdGuard Home][agh] and [dnsmasq][dnsmasq] in combination.

# How does AdGuard Home compare to traditional ad blockers

![icon]({static}/images/2025/adguardhome/adguard_home.svg)


It depends.

DNS sinkholing is capable of blocking a big percentage of ads, but it lacks the
flexibility and the power of traditional ad blockers. You can get a good impression about
the difference between these methods by reading [this article][blog-adaway], which compares
AdGuard for Android (a traditional ad blocker) to hosts-level ad blockers (which are almost
identical to DNS-based blockers in their capabilities). This level of protection is enough
for some users.

Additionally, using a DNS-based blocker can help to block ads, tracking and analytics requests
on other types of devices, such as SmartTVs, smart speakers or other kinds of IoT devices
(on which you can't install traditional ad blockers).

# Known limitations

Here are some examples of what cannot be blocked by a DNS-level blocker:

- YouTube, Twitch ads;
- Facebook, Twitter, Instagram sponsored posts.

Essentially, any advertising that shares a domain with content cannot be blocked by a
DNS-level blocker.

Is there a chance to handle this in the future?  DNS will never be enough to do this. Our only 
option is to use a content blocking proxy like the standalone AdGuard applications.


# Installation 

[AdGuard Home][agh] is hosted on [github][repo].  You can download a pre-build
binary from its [releases page][releases].  Since [AdGuard Home][agh] is developed
in Go language, its binaries seem to be fairly portable.

Installing on Alpine Linux is fairly simple.  I am using an Ansible playbook for this,
but the process is as follows:

0. I am using [dnsmasq][dnsmasq] with [AdGuard Home][agh].  So the pre-requisite
   step is to change the [dnsmasq][dnsmasq] so that it does *not* listen on port 53/UDP.
   This is done with the line:
   ```text
   port=5353
   ```
1. Download binary from the [releases page][releases].
2. Unpack the binary into your destination directory.  I use `/usr/local/lib/AdGuardHome`.
3. [AdGuard Home][agh] reads configuration and saves some data in its installation
   directory.  I relocate these via symbolic links:
   ```bash
   agh_home=/usr/local/lib/AdGuardHome
   ln -s /etc/AdGuardHome.yaml ${agh_home}/AdGuardHome.yaml
   ln -s /var/lib/AdGuardHome ${agh_home}/data
   ```
4. Create the start|stop scripts.  I am using:
   ```bash   
   #!/bin/sh
   # Startup script
   appdir=/usr/local/lib/AdGuardHome
   mkdir -p "$(readlink -f "$appdir/data")"
   chmod 0700 "$(readlink -f "$appdir/data")"
   if [ ! -f /etc/AdGuardHome.yaml ] ; then
     cp /etc/AdGuardHome.proto /etc/AdGuardHome.yaml
   elif [ /etc/AdGuardHome.proto -nt /etc/AdGuardHome.yaml ] ; then
     cp /etc/AdGuardHome.proto /etc/AdGuardHome.yaml
   fi
   $appdir/AdGuardHome &
   ```
   and
   ```bash
   # Shutdown script
   #!/bin/sh
   killall AdGuardHome
   ```
   The startup script is doing a few things:
   - Make sure that the data directory has the right permissions.
   - Initialize configuration if needed (More on that later).
5. The default configuration will listen on port 3000/TCP.  Connect to
   it with a web browser to configure [AdGuard Home][agh].


![icon]({static}/images/2025/adguardhome/adguard-home-screen-alt.png)


# Configuration

Actually, for the initial configuration I prefer to use prepared file.  This is
the `AdGuardHome.proto` file that is referenced in the `start` script.

This YAML file can contain the settings that you want to override from the defaults.

I am using this file:

```yaml
http:
  address: 10.0.2.254:3000
users:
- name: admin
  password: $2a$....DELETED....
dns:
  bind_hosts:
    - 0.0.0.0
  port: 53
  upstream_dns:
    - '# https://dns10.quad9.net/dns-query'
    - 127.0.0.1:5353
  hostsfile_enabled: false
  use_private_ptr_resolvers: true
  local_ptr_upstreams:
    - 127.0.0.1:5353
log:
  enabled: true
  file: "/var/log/AdGuardHome.log"

```

The `http` section is fixing the IP address and port it will listen to.

The `users` section can be used to configure authentication.  You can have multiple
user names and passwords.  The passwords are based on Bcryp2 hashing.  You can use:
https://www.devglan.com/online-tools/bcrypt-hash-generator to generate the hashes.

If you do not want to do user authentication, for example, if placing behind a reverse
proxy that does the authentication already, you can use:

```
users: []
```

This disables the internal user name and password authentication.

In the `dns` section, I am doing a number of tweaks:

* `upstream dns` and `local_ptr_upstream` are configured to point to `127.0.0.1:5353`
  which is the locally running [dnsmasq][dnsmasq] that was re-configured earlier.
* `hostfile_enabled` is set to `false` to disable `/etc/hosts` file usage.  Personally
  I expect the host names defined by `/etc/hosts` *only* to be used by the local system,
  and shouldn't be exported to DNS.

# Reverse Proxy

Reverse proxying can be used to provide for example single sign on (SSO) by handling
the authentication on the reverse proxy itself.  This is very simple to do.  It can
be done either at the virtual host level, or at a sub folder level.  In nginx you can use
the code:

```text
location /adghome/ {
    proxy_pass http://10.0.2.254:3000/;
}
```
Or using a virtual host:

```text
location / {
    proxy_pass http://10.0.2.254:3000/;
}
```

# Using it

Once properly configured, clients will receive via DHCP the [AdGuard Home][agh] and
start using directly.  You can browse to the user interface and you will see
statistics and configuration.

# Conclusion

In short, [AdGuard Home][agh] is much like your run-of-the-mill browser ad blocker, but rather than
being a plug-in on your favourite web browser, [AdGuard Home][agh] is a fully-fledged server
application which runs on a separate machine somewhere on your network (or perhaps even on a
VPS you own). Its primary goal is to provide your network with a mechanism to actively block
certain requests that websites you visit make – in this case, requests for adverts, malware,
or various other malicious things.


  [repo]: https://github.com/AdguardTeam/AdGuardHome
  [pihole]: https://pi-hole.net/
  [agh]: https://adguard.com/en/adguard-home/overview.html
  [releases]: https://github.com/AdguardTeam/AdGuardHome/releases
  [dnsmasq]: https://thekelleys.org.uk/dnsmasq/doc.html
  [blog-adaway]: https://adguard.com/blog/adguard-vs-adaway-dns66.html
