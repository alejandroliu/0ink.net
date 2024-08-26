---
title: 2024-12-31-wayland-gotchas
date: "2024-06-03"
author: alex
---
So the day of wayland is coming.  As of today the gotchas I have are:

- vnc on the desktop
  - wayvnc (required wlroots)
- global hotkeys &rarr; macro recoding
  - need to be implemented in compositor
- tiling shortcuts
  - need to be implemented in compositor
- screensaver
  - swaylock  
- keyboard indicator
- screen grabber
  - need to be implemented in compositor (hotkeys) and using tools like grim or slurp
- xrandr monitor equivalent
  - kanshi
  - wlr-randr
- wmctl replacement
  - wlrctrl
- barrier/inputleap replacement
  - https://github.com/feschber/lan-mouse
  


***

See: https://github.com/solarkraft/awesome-wlroots

Compositors

- [hikari](https://hikari.acmelabs.space/) : Interesting, but not easily discoverable
- [labwc](https://github.com/johanmalm/labwc) : OpenBox like.  Recommended by LXQt project.


Screensaver hacks

- https://sr.ht/~mstoeckl/wscreensaver/
- https://github.com/mstoeckl/swaylock-plugin
- https://leimstift.de/2023/12/12/getting-screensavers-to-work-on-wayland/

