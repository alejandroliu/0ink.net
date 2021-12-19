---
title: My tale of IPv6 whoes
---

My ISP provider is [KPN][kpn].  They recently enabled
IPv6 in my street.  I was using before a IPv6 Tunnel Broker,
starting with [SixXS][sixxs] and after they went out,
with [Hurricane Electric][he].  So naturally,
I decided to switch to KPN's native IPv6 service.

They provide a /64 prefix, which is reasonable.  Would be better
if they provided a /48, but /64 is better than other providers.

So to start using KPN as the IPv6 turned out very easy.  Their default
configuration works right out of the box if you have single flat
network.

I used to have a router/FW between the KPN modem and my network,
but at some point I decided to go for a flat network design.  With
this, (without having to do anything) once KPN enabled IPv6, all my
equipment that was IPv6 capable started using IPv6.  It was like
magic.

I run a number of server systems in my home network, using
[Alpine Linux][alpine] as its operating system.

For some reason, these servers would be able to use IPv6 at first
(either via static configuration or auto-configuration), but stop
working after a few minutes (often after 65 seconds).

- ... ipv6 debugging and what happens, how I fixed it

- why is better to have a device between modem and lan
- use of IPv6 NAT vs. simply routing into /64
- splitting /64 and why /80 is not good
- ndp proxy : basic kernel
- daemon's approches
- ideas around
- ndpbr script



 [kpn]: https://www.kpn.com "KPN"
 [sixxs]: https://www.sixxs.net "SixXS"
 [he]: https://tunnelbroker.net "Hurricane Electric"
 [alpine]: https://alpinelinux.org "Alpine Linux"

