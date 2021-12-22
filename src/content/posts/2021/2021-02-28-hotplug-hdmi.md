---
title: Linux HDMI hotplug
date: 2021-02-28
---

The point of this article is to document I workaround that I came
up with to handle a HDMI KVM switch.

What happens is that if my Linux PC is turned on while the KVM switch
is selecting the other PC, it fails to initialize the display, so
when you switch back to the Linux PC, no display is shown.

The trick for this to work is to the use of [udev][udev] and [xrandr][xrandr].

We use [udev][udev] to detect the monitor being plugged in, and we use
[xrandr][xrandr] to tell X windows to update the display.

# Figuring out udev

First in the agenda is to figure out what kind of event we should
be looking at.  For that, we use the command:

```
udevadm monitor
```

With that we can determine what kind of [udev][udev] events to look
for (if any).

Next we need to figure out what keys we need to match.  Unfortunately
there is some guess work required as you need to figure out the `/dev`
device path, whereas `udevadm monitor` shows a `/devices/` path.

However, you manage, you need to use the following command:

```
udevadm info --query=all --name=/dev/dri/card0 --attribute-walk
```

This will show possible attributes in the [udev][udev] rules key
format.

Once we know the keys to use, we can know create the rules files.

Rules are located in two locations:

* `/usr/lib/udev/rules.d/` : for system default rules
* `/etc/udev/rules.d/` : for local specific rules

Essentially, we are waiting for the monitor configuration to change
and when that happens we will run a script. This is accomplish with
the following rules file (99-xwin-hotplug.rules):

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=paraiso-light&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/xwin-hotplug/99-xwin-hotplug.rules"></script>

# Running xrandr

The script that is kicked off by [udev][udev] does the following:

1. Check if `Xorg` is running.
2. Assumes `DISPLAY` is `:0.0` (only one local display!) and tries to
   determine a suitable `XAUTHORITY` file.
3. Run [xrandr][xrandr] to try to determine what is the `connected`
   display.
4. Calls `xrandr --output "$monitor" --auto` to re-configure the display
5. Run `xrefresh` for good measure.

See script:

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=paraiso-light&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/raw/master/snippets/xwin-hotplug/xwin-hotplug"></script>

# See Also

* [Beginners guide to udev](https://www.thegeekdiary.com/beginners-guide-to-udev-in-linux/)
* [Tutorial on how to write basic udev rules](https://linuxconfig.org/tutorial-on-how-to-write-basic-udev-rules-in-linux)
* [Intro to udev](https://opensource.com/article/18/11/udev)

[udev]: https://wiki.debian.org/udev
[xrandr]: https://xorg-team.pages.debian.net/xorg/howto/use-xrandr.html

