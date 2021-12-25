---
title: Linux Post Install tasks
tags: browser, config, software
---

These tips are for [void linux][void] as that is the distro
I am using nowadays.

- mate tricks: change background from cli
    - `dconf write /org/mate/desktop/background/picture-filename "'PATH-TO-JPEG'"`
- web page to check if your browser is html5 compliant:
    - [https://www.youtube.com/html5](https://www.youtube.com/html5)

# HotKeys

- Install `xbindkeys`
- Add to startup? `$HOME/.xprofile`
- Create default config with `xbindkeys -d > $HOME/.xbindkeysrc`
- Lookup key combinations:
    - `xbindkeys --multikey` or
    - `xbindkeys --key`
- update bindings `xbindkeys --poll-rc`
- `rofi`
    - A good addition to this is `rofi`.  Which is a dynamic menu.
    - Create a xbindkey shortcut to run rofi with:
	- `rofi -show-icons  -modi drun,window  -show drun`

# Additional software

- Additional software (Tested on void linux):
  - Tip: use `sed -e 's/#.*$//'` to strip comments!

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=paraiso-light&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/swlist-extras.txt"></script>



 [void]: https://voidlinux.org "Void Linux"
