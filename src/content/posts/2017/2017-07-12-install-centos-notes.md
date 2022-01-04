---
title: Centos Install notes
tags: alpine, application, browser, centos, git, installation, linux, login, settings, windows
---

Set-up `local.repo`

yum installs:

- nfs-utils autofs
- @x11
- @xfce
- wget
- dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts
- xorg-x11-fonts-{Type1,misc,75dpi,100dpi}
- bitmap-console-fonts bitmap-fixed-fonts bitmap-fonts-compat bitmap-lucida-typewriter-fonts
- ucs-miscfixed-fonts urw-fonts
- open-sans-fonts
- webcore-fonts webcore-fonts-vista
- liberation-mono-fonts liberation-sans-fonts liberation-serif-fonts
- bitstream-vera-sans-fonts bitstream-vera-serif-fonts
- gnu-free-{mono,sans,serif}-fonts
- tk
- firefox
- mplayer ffmpeg alsa-utils 
- xsensors xfce4-sensors-plugin
- keepassx
- git

[Building RPM packages with mock](https://blog.packagecloud.io/eng/2015/05/11/building-rpm-packages-with-mock/)
and [Centos mock overview](https://github.com/perfsonar/project/wiki/CentOS-Mock-Overview)

[Using mock with fedora](https://fedoraproject.org/wiki/Using_Mock_to_test_package_builds#Building_packages_that_depend_on_packages_not_in_a_repository)

[packaging rpms with mock](http://blog.packagecloud.io/eng/2015/05/11/building-rpm-packages-with-mock/)

[Adding trusted certs…](https://gist.github.com/oussemos/cf81d86a446544bfa9c92f3576306aff) or [rehat solution](https://access.redhat.com/solutions/1549003)

[php using ssl](http://www.devdungeon.com/content/how-use-ssl-sockets-php)

[Chrome on Centos7](https://www.tecmint.com/install-google-chrome-on-redhat-centos-fedora-linux/) from [google repos](https://www.google.com/linuxrepositories/).

## travis ci installation

- Install ruby (must be greater than 1.9.3, 2.0.0 recomended)
- Additional dependencies (through yum)
- ruby-ffi

As normal user:

- `gem install travis -v 1.8.8 --no-rdoc --no-ri`

For a new application...

```
travis enable
travis settings builds_only_with_travis_yml -t
```

[PRoot](https://github.com/proot-me/PRoot/releases)

project
  -module: centos/alpine
      -module: proot

- [travis ci custom build](https://docs.travis-ci.com/user/customizing-the-build/)

- install: install any dependencies required
- script: run the build script

# Nameing conventions

Naming tmXXXXYYYYRRRR

* tmc7r1 : centos 7 template
* tmwin7r1 : not using these, I think it is better to do fresh install...
* tmal3r1 :  alpine linux template. 
   - after boot:
     1. mount xvda1 on /media/xvda1 and run setup-alpine
     2. modify /etc/inittab /etc/securetty to allow ttyS0 (console) login
     3. may need to switch cdrom as needed.

Sample vm names:

* winvm1 : windows vm
* cvm2 : centos vm
* alvm3 : alpine linux vm



More complete guides: 

- [Rasperry Pi router](https://wiki.alpinelinux.org/wiki/Linux_Router_with_VPN_on_a_Raspberry_Pi)
- [AWall](https://wiki.alpinelinux.org/wiki/How-To_Alpine_Wall)
- [webserver + php](https://wiki.alpinelinux.org/wiki/Nginx)
- [Networking](https://wiki.alpinelinux.org/wiki/Configure_Networking)
- [DNSMasq IPv6 stuff](https://egustafson.github.io/ipv6-dhcpv6.html)
- [Another DNSmasq + ipv6](https://hveem.no/using-dnsmasq-for-dhcpv6)

Second wifi on OpenWrt

-
 [cucumber-wifi](https://cucumberwifi.io/community/tutorials/openwrt-adding-second-ssid.html)
- [smalltech](https://www.smallbusinesstech.net/more-complicated-instructions/openwrt/hosting-two-wifi-networks-on-one-openwrt-router)
