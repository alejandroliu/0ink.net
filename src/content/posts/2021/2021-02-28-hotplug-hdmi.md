---
title: Linux HDMI hotplug
date: 2022-10-21
tags: configuration, device, linux, windows
---
<!--
  **UPDATE**: This is Xserver focused.  For console solution see [[../2023/2023-12-31-console-hotplug.md|Console Hotplug]] article.
-->

The point of this article is to document I workaround that I came
up with to handle a HDMI KVM switch.

What happens is that if my Linux PC is turned on while the KVM switch
is selecting the other PC, it fails to initialize the display, so
when you switch back to the Linux PC, no display is shown.

The trick for this to work is to the use of [udev][udev] and [xrandr][xrandr].

We use [udev][udev] to detect the monitor being plugged in, and we use
[xrandr][xrandr] to tell X windows to update the display.

I don't think this happens very often, as the Linux defaults will
handle things properly most of the time.  In my case there were
a number of configurations where this makes sense:

- Using the old [X display manager][xdm] (XDM).  Which doesn't
  seem to care for display change events.\
  Personally, I like using XDM because is very minimalistic.
- Using a 4K HDMI EDID editor but connecting a monitor that does
  not support 4K.

# Figuring out udev

First in the agenda is to figure out what kind of event we should
be looking at.  For that, we use the command:

```
udevadm monitor
```

or

```
udevadm monitor --property
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

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/main/snippets/2021/xwin-hotplug/99-xwin-hotplug.rules"></script>

# Running xrandr

The script that is kicked off by [udev][udev] is called `xwin-houtplug`
and does the following:

1. Check if `DISPLAY` is set. (i.e. running from Xorg session)
2. Check if `Xorg` is running.
3. Determine the `DISPLAY` and a suitable `XAUTHORITY` file.
4. Run [xrandr][xrandr] to find connected monitors and relevant display modes.
5. Check if the user has configured a *preferred* video mode.
6. Use the *preferred* video mode or auto-detect:
   - *Preferred*: `xrandr --output $monitor --mode $mode`
   - auto-detect: `xrandr --output $monitor --auto`
5. Run `xrefresh` for good measure.

See script:

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/main/snippets/2021/xwin-hotplug/xwin-hotplug"></script>

To configure the *preferred* video mode, create a file
`/etc/X11/vmode.prefs` with the format:

```text
output:mode
```

Example:

```text
HDMI-A-0:1920x1080
HDMI-A-1:2560x1440
DisplayPort-0:1280x720
```

Refer to the output of [xrandr][xrandr] for the connection names.

# monitor warmplug

Run the `xwin-hotplug` script when Xorg starts.  This will make sure
that the selected *preferred* video mode is used when the X session
starts.

# Configuring Kernel video modes

You can select a linux console *preferred* video mode by adding the
`video` option to the command line.

For example:

```text
video=HDMI-A-0:1280x720
```

**NOTE**: The output specification here follows Linux kernel conventions
which are different from [xrandr][xrandr].

To get the name and current status of connectors, you can use the
following shell oneliner:

```bash
$ for p in /sys/class/drm/*/status; do con=${p%/status}; echo -n "${con#*/card?-}: "; cat $p; done

DVI-I-1: connected
HDMI-A-1: disconnected
VGA-1: disconnected
```
# See Also

* [Beginners guide to udev](https://www.thegeekdiary.com/beginners-guide-to-udev-in-linux/)
* [Tutorial on how to write basic udev rules](https://linuxconfig.org/tutorial-on-how-to-write-basic-udev-rules-in-linux)
* [Intro to udev](https://opensource.com/article/18/11/udev)
* [Kernel mode setting](https://wiki.archlinux.org/title/Kernel_mode_setting)

[udev]: https://wiki.debian.org/udev
[xrandr]: https://xorg-team.pages.debian.net/xorg/howto/use-xrandr.html
[xdm]: https://en.wikipedia.org/wiki/XDM_(display_manager)
