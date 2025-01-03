---
title: Saving Cinnamon customizations
date: "2025-01-02"
author: alex
tags: desktop, configuration, settings, mouse, windows, tools, editor
---
![Settings]({static}/images/2025/cinn-settings.png)

When I switched Desktop Environments towards [Cinnamon][cd], I wanted
to save configuration settings so I could restore them later if I moved
to a different PC.

Pre-requisites:

We need the following packages

- dconf

Optionally you may want to install:

- dconf-editor
- glib

The simplest way is to modify the settings using the built-in [Cinnamon][cd]
UI tools or `cinnamon-settings`.  Once you have all the settings as you
want run:

```bash
dconf dump / > customizations.ini
```

Or if you want to limit to cinnamon settings:


```bash
dconf dump /org/cinnamon/  > cinnamon.ini
dconf dump /org/gnome/ > gnome.ini

```

We need to dump `cinnamon` and `gnome` because [cinnamon][cd] is gnome derived
and some settings are stored there.

See the [manpage for dconf][dconf] for more details.

The result of these commands is a text file in [INI][ini] format.  Which can be
edited with a text editor.  I would normally edit the text file as it would
contain some settings that I would prefer to leave as default.

When it is time to restore the settings you need to use the command:

```bash
dconf load / < customizations.ini
```

or

```bash
dconf load /org/cinnamon/  < cinnamon.ini
dconf load /org/gnome/ < gnome.ini
```

Modifying the [INI][ini] file lets you access some settings not available
directly from the GUI.  To explore what is possible you can use the
following commands:

```bash
gsettings list-schemas
```

or from the GUI:

```bash
dconf-editor
```
![dconf]({static}/images/2025/dconf.png)


  [cd]: https://github.com/linuxmint/cinnamon
  [dconf]: https://man.archlinux.org/man/dconf.1.en
  [ini]: https://en.wikipedia.org/wiki/INI_file

