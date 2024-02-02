---
title: Console hot plug
tags: boot, linux
---
This is an update to my post about [[../2021/2021-02-28-hotplug-hdmi.md|HDMI hotplug]].

Back then was written in the context of `Xorg` server hotplug and made use of the `xrandr`
command to set-up the monitor.

If you are not running `X windows`, then `xrandr` is a non starter.

This article is the continuation with more focus on the Linux console.

It uses the same [udev rules][udev-rules] as in the previous article to run
the [xwin-hotplug][xwin-hotplug] script.

However, if it doesn't find an `Xorg` process running, it does ...

TODO:


***

Examining the output of `dmesg`, turns out that the system is failing to read **EDID** data.

After reading an article on kernel mode setting, you can override the EDID data, however
you need to generate a suitable EDID file.  Since my system is reading the EDID on boot up
what I am doing is first caching the EDID file.

On boot-up, I check if there is a monitor connected.  If it is, we save the EDID data.  I use
the `/sys/class/drm/card*` interface to determine the `status` (`connected`) and read the
EDID data from here.

***


1. set-up the kernel to read the latest EDID file
2. force the kernel to re-read the EDID data.

```
640 	480 	60 Hz 	31.475 kHz 	ModeLine "640x480" 25.18 640 656 752 800 480 490 492 525 -HSync -VSync
```

References:

- https://wiki.archlinux.org/title/kernel_mode_setting
- https://linuxlink.timesys.com/docs/wiki/engineering/HOWTO_Use_debugfs
- https://www.mythtv.org/wiki/Modeline_Database#VESA_ModePool
- https://github.com/akatrevorjay/edid-generator

 [xwin-hotplug]: https://github.com/alejandroliu/0ink.net/blob/main/snippets/2021/xwin-hotplug/xwin-hotplug
 [edid-cache]:  https://github.com/alejandroliu/0ink.net/blob/main/snippets/2021/xwin-hotplug/edid-cache
 [udev-rules]: https://github.com/alejandroliu/0ink.net/blob/main/snippets/2021/xwin-hotplug/99-xwin-hotplug.rules
