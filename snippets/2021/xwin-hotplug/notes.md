# forced EDID

Working:

- In Kernel command line:
  - `video=HDMI-A-1:2560x1440`
- In /etc/X11/profile.d/00-resolution.sh
  - `xrandr --output HDMI-A-0 --mode 2560x1440`


- TODO:
  - Have file with "output:mode"
  - X11/profile.d/00-resolution sets the mode from the file
  - xwin-hotplug reads from output-mode to set modes.

***

Tested:

- setting resolution from command line:
  - `video=HDMI-A-1:1280x720`
  - Worked to set the video
  - Did not work with the dummy 4K plug
- setting resolution using xrandr --output <name> --mode <WxH>
  - DID NOT WORK -- probably because monitor was not active
- using forced EDID
  - DID NOT WORK


Scenarios

- hotpluging a new monitor
- KVM monitor switching (no HDMI dummy)
- Using a HDMI dummy plug with wrong resolution

# hotpluging a new monitor

Simply call the xrandr auto

# KVM monitor switching (no HDMI dummy)

Also use xrandr auto.

# Using HDMI dummy plug

Use xrandr but instead of auto a predefined setting.

Maybe:

- Plug-in physical monitor
- save EDID data

Interesting modules:

- drm
  - edid_firmware

***
- command to save EDID on specific ports
- at boot, we check if an edid has

# References

-
- https://wiki.archlinux.org/title/HiDPI
- https://linuxlink.timesys.com/docs/wiki/engineering/HOWTO_Use_debugfs
- https://www.kernel.org/doc/Documentation/fb/modedb.txt

