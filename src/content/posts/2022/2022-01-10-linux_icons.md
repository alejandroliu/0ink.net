---
title: Linux Icons
tags: desktop, linux
---

A quick note on how to add icons to menus in a Linux desktop.

1. Create the icon image in: `/usr/share/pixmaps`.
    - png and svg (and maybe others) are supported.
    - 24x24 seems to be a good size for menus.
2. You need to create a `.desktop` file in `/usr/share/applications`.
    - [Desktop menu specification](https://specifications.freedesktop.org/menu-spec/latest/index.html)
    - [Registered categories](https://specifications.freedesktop.org/menu-spec/latest/apa.html)

User desktop files:

- These are located in:
    - `$HOME/.local/share/applications`
- Icons can be found here:
    - `$HOME/.local/icons`
    - **I am not sure about this one**
- Autostart files:
    - `$HOME/.config/autostart`.

See also: [archlinux wiki](https://wiki.archlinux.org/title/desktop_entries)

There is a command line utility:

- [xdg-desktop-menu](https://linux.die.net/man/1/xdg-desktop-menu)


