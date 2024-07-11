---
title: Tweaking HDMI dummies
date: "2024-02-02"
author: alex
tags: boot, linux
---
[toc]
***

![dummy]({static}/images/2024/dummy.png)

This is a follow-up to my post about [[../2021/2021-02-28-hotplug-hdmi.md|HDMI hotplug]].

Back then I wrote it to handle a KVM switch and how it would deal with switching
monitors and how Linux handled when the monitor was *not* plugged in.

Since then I discovered [HDMI dummy plugs][dummies].  These are small adapters that
connect to an HDMI and fool the computer into thinking there is a monitor still
connected.

Using it is really a matter of preference.

On my desk, I have a KVM connecting a Linux desktop and a Windows laptop.  When the KVM
connects to the Windows laptop I would configure the system to extend the desktop to
two monitors.  When I switch from the Windows laptop to my Linux desktop with the
KVM switch, the Windows Operating system detects that the monitor is disconnected
and moves all the opened windows from the external monitor (which is now disconnected)
to the Laptop display.  While this is the _common sense_ thing to do, I don't find
the experience pleasent.

By using the [HDMI dummy plug][dummies] adaptor, Windows thinks that the monitor
still is connected while the KVM switches to the other computer.  So when
I switch back, all the windows stay put.

So the issues that I was having back as described in [[../2021/2021-02-28-hotplug-hdmi.md|HDMI hotplug]]
would not happen as the monitor looks like is always connected.

Furthermore, looking at the state of software under Linux, the Operating System
already handles monitor hotplugs gracefully.  Similarly, Desktop Environments 
work without much issues with monitors being plugged or unplugged on the fly.
Also in [[../2021/2021-02-28-hotplug-hdmi.md|HDMI hotplug]] I was using the
[XDM (Display Manager)][XDM] which was initially written back 1988, and
is one of the most rudimentary display managers.

![XDM (Display Manager)]({static}/images/2024/xdm.png)

Of course things in life are never simple.  So this is what happened.

When I first started using [HDMI dummies][dummies] I had a 1080p FHD monitor and 1080p
dummies.  Recently I upgraded my main monitor to a QHD monitor.  So the 1080p dummy
was not able to reach the QHD (1440p resoluation).  Of course, there is no 
1440p dummy, so I bought a 4K HDMI dummy.  Which made things a little bit challenging
because the cheapo 4K HDMI dummy would insist to the computer that the preferred
resolution was 4K, but my monitor would not be able to display that.

Normally monitors use [EDID][EDID] data to tell the computer what are the preferred
resolutions.  A good [HDMI dummy][dummies] would then cache the [EDID][EDID] information
from the monitor and only present a compatible [EDID][EDID] to the computer.  For some
reason this did not work.

Luckly Linux allows to force [EDID][EDID] to be overriden.  To do that this is
what i had to do.

# Prepare EDID blob

First plug in the monitor directy *without* the [HDMI dummy][dummies].  Determine
the connection in use:

```bash
for p in /sys/class/drm/*/status; do con=${p%/status}; echo -n "${con#*/card?-}: "; cat $p; done
```

Read the [EDID][EDID] blob from `/sys/class/drm/card0{connection}/edid`.

```bash
cat < /sys/class/drm/card0-HDMI-A-1/edid` > monitor.bin
```

Use the command [parse-edid][man-parse-edid] to read the blob and make sure it
contains valid data.

Save it to `/usr/lib/firmware/edid`.  I would save it to a file with the
monitor model name and `bin` extension.


# Modify Kernel command line

Add the following option to the Linux kernel command line:

```bash
drm.edid_firmware=HDMI-A-1:edid/PHL325B1L.bin
```

Change `HDMI-A-1` with the right connector as seen using a previous command.
Replace `PHL325B1L.bin` with the name of the [EDID][EDID] blob you created earlier.

# Update initramfs

Under [voidlinux][void], the [dracut][man-dracut] utility is used to generate the
initramfs.

Create a file in `/etc/dracut.conf.d/` with the configuration:

```bash
# /etc/dracut.conf.d/50-fw.conf 
install_items+=" /usr/lib/firmware/edid/PHL325B1L.bin "

```

And generate the new initramfs:

```bash
dracut --force
```

# Reboot

At this point all is ready.  Shutdown the computer, plug the monitor
using the [HDMI dummy][dummies].

# Post boot EDID

Alternatively, you could use this script to force EDID after boot:

```bash
#!/bin/sh
#
# Script to force EDID settings
#
set -euf -o pipefail

#
# Customize these settings
#
EDID_BIN=/usr/lib/edid/PHL325B1L.bin
output=HDMI-A-1
rows=45
cols=160

# Use parse-edid to verify
# save /sys/class/drm/card*/edid
debugfs=/sys/kernel/debug

if [ ! -d $debugfs/dri ] ; then
  umount=true
  mount -t debugfs debugfs $debugfs
  trap "umount $debugfs" EXIT
fi

dd if=$EDID_BIN of=$debugfs/dri/0/$output/edid_override
echo 1 | dd of=$debugfs/dri/0/$output/trigger_hotplug

for n in $(seq 1 6)
do
(
  tput sc
  printf '\033[1;'$rows'r'
  tput rc
  stty rows $rows cols $cols
) < /dev/tty$n >/dev/tty$n 2>&1
done
```

References:

- https://wiki.archlinux.org/title/kernel_mode_setting#Forcing_modes_and_EDID
- https://linuxlink.timesys.com/docs/wiki/engineering/HOWTO_Use_debugfs

 [dummies]: https://en-wiki.ikoula.com/en/HDMI_display_emulator
 [XDM]: https://en.wikipedia.org/wiki/XDM_(display_manager)
 [EDID]: https://en.wikipedia.org/wiki/Extended_Display_Identification_Data
 [read-edid]: http://www.polypux.org/projects/read-edid/
 [man-parse-edid]: https://manpages.debian.org/wheezy/read-edid/parse-edid.1
 [void]: https://voidlinux.org/
 [man-dracut]: https://man7.org/linux/man-pages/man8/dracut.8.html
 
 
