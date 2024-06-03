---
title: Linux desktop default apps
date: "2024-06-01"
author: alex
---
[toc]
***
![freedesktop]({static}/images/2024/freedesktop-logo.png)


This is one of the most annoying bits about configuring things in Linux.

When you install more than one Linux application that handles the same file type
sometimes the default application that will be run will not match your expectations.
To check what application will be run you can use the UI or you can use check
it from the command line using the `xdg-mime` command.  Examples:

```bash
xdg-mime query default x-scheme-handler/mailto
xdg-mime query default image/jpeg
```

# User configuration

You can use your Linux Desktop environment's User interface to set you
**preferred** application to handle that file type.

In the case of [LXQT][lxqt] which is the current Desktop Environment that I am using
this can be found in:

**Preferences &rarr; LXQt Settings &rarr; File Associations**

Or run: `lxqt-config-file-associations`

![file-associations]({static}/images/2024/file-associations.png)


If you want to modify files this configuration can found here:

- `~/.config/mimeapps.list`
- `~/.config/lxqt-mimeapps.list` **Only in LXQt**, in case you have application defaults
  specific to [LXQt][lxqt].

These files are in standard `.ini` format, example:

```ini
[Default Applications]
x-scheme-handler/http=Firefox.desktop
x-scheme-handler/https=Firefox.desktop
text/html=Firefox.desktop
application/pdf=qpdfview.desktop
inode/directory=pcmanfm-qt.desktop
image/jpeg=lximage-qt.desktop
image/jpg=lximage-qt.desktop
image/png=lximage-qt.desktop
image/gif=lximage-qt.desktop
image/webp=lximage-qt.desktop
```

In this file you can specify:

- The default application to run when double clicking an icon
- The list of applications that will be shown in the `Open with...` menu
- The list of applications that will be **REMOVED** from the `Open with...` menu

For more info on the file format see [specs][specs]. 

Additonally you can use the `xdg-mime` command to modify the defaults.  Examples:

```bash
xdg-mime default thunderbird.desktop x-scheme-handler/mailto
xdg-mime default firefox-esr.desktop text/html

```

# System-wide configuration

For configuring the default applications for all users you can use:

- `/etc/xdg/mimeapps.list`

The format follows the same spec as the user file and is documented in this [specification][spec].

The configuration file location can be overriden with the `XDG_CONFIG_DIRS` environment
variable.

# Additional files

Keep in mind if you are using [Flatpak][flatpak]'s, these will also introduce its own
extensions that you may need to pay attention to.

Due ot the way of how the Linux desktop have evolved the following locations will also
be used.  Make sure these do not exist as they may cause unexpected configurations:

- `/etc/lxqt-mimeapps.list`
- `/etc/mimeapps.list`
- `/etc/xdg/lxqt-mimeapps.list`
- `/usr/share/lxqt-mimeapps.list`
- `/usr/share/mimeapps.list`
- `/usr/local/share/applications/lxqt-mimeapps.list`
- `/usr/local/share/applications/mimeapps.list`
- `~/.local/share/applications/lxqt-mimeapps.list`
- `~/.local/share/applications/mimeapps.list`
- `~/.local/share/applications/defaults.list`


# References

- https://askubuntu.com/questions/1306025/how-do-i-set-the-default-email-client-in-lxqt
- https://wiki.archlinux.org/title/XDG_MIME_Applications
- https://specifications.freedesktop.org/shared-mime-info-spec/shared-mime-info-spec-latest.html#s2_layout
- https://wiki.debian.org/DefaultPrograms#GUI_Applications
- https://specifications.freedesktop.org/mime-apps-spec/mime-apps-spec-1.0.1.html#associations


  [lxqt]: https://lxqt-project.org/
  [specs]: https://specifications.freedesktop.org/mime-apps-spec/mime-apps-spec-1.0.1.html#associations
  [flatpak]:  https://www.flatpak.org/
  
  