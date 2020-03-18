---
title: Linux Post Install tasks
---

These tips are for [void linux][void] as that is the distro
I am using nowadays.

* * *

Additional software (Tested on void linux):

Tip: use `sed -e 's/#.*$//'` to strip comments!

<script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/linux-post-install/void-swlist.txt?footer=minimal"></script>


## Media support in FireFox

Check [here](https://www.youtube.com/html5) to make sure FireFox
can play `mp4` files.

## HotKeys

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



 [void]: https://voidlinux.org "Void Linux"

Punch list:

- [ ] Printer/Scanner
- [ ] RedShift
- [ ] SafeEyes
- [ ] ownCLoud
- [ ] Chat
- [ ] Screen Saver
- [ ] Keyboard
- [ ] xbindkeys


