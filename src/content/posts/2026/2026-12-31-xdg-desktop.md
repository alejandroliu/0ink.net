---
title: Linux Desktop file tipes
tags: desktop, github, library, linux
---

- desktop specification
  - special keys
    - X-LXQt-Need-Tray=true
    - NotShowIn=KDE;GNOME;
- autostart directories
  - /etc/xdg/autostart
  - $HOME/.config/autostart
- $HOME/.local/share/{applications,icons}
- user-dirs : $HOME/.config/user-dirs and /etc/xdg/user-dirs.defaults



Tips for Linux dekstop files:

- https://edoceo.com/sys/xfce-custom-uri-handler

Example:

```
[Desktop Entry]
Encoding=UTF-8
Name=Link to GitHub - PHPOffice/PhpSpreadsheet: A pure PHP library for reading and writing spreadsheet files
Type=Link
URL=https://github.com/PHPOffice/PhpSpreadsheet
Icon=mate-fs-bookmark
```




