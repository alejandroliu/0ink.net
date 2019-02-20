---
title: Centos Install notes
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

