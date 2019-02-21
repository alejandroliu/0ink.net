---
title: Linux Desktop tweaks
---

Additional software (Tested on void linux):

Note: use `sed -e 's/#.*$//'` to strip comments!


```
git			# I need this to interact with github
tcl			# gui scripts
tk
geany			# text editor and IDE
geany-plugins
geany-plugins-extra
mplayer			# media support
ffmpeg
vlc
gst-libav		# void-linux add mp4 support to firefox
surf			# support for webapps
xprop
dmenu
synergy-gui		# software kvm switch
gthumb			# photo manager
libreoffice		# Office applications
mypaint			# MSPaint like ... alternatives: mtpaint or grafx2 for a more old-skool pixel-art feel


```

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

## Configure keyboard

Create configuration file: `/etc/X11/xorg.conf.d/30-keyboard.conf`

```
Section "InputClass"
        Identifier "keyboard-all"
        Option "XkbLayout" "us"
        # Option "XkbModel" "pc105"
        Option "XkbVariant" "altgr-intl"
        # Option "XkbVariant" "intl"
        # MatchIsKeyboard "on"
EndSection
```
For programmers `altgr-intl` is more adecuate.  Normal users would
probably use `intl` for the `XkbVariant`

If this doesn't work running the command:

```
setxkbmap -rules evdev -model evdev -layout us -variant altgr-intl
```

From `xinitrc` may be needed.

## void linux specifics

Enable automounting:

Install:

```
autofs
nfs-utils
```
Enable services:

```
ln -s /etc/sv/{statd,rpcbind,autofs} /var/service
```

## MATE Desktop specifics

Packages:

```
caja-open-terminal
```

## LXDM specifics

MATE under Void Linux uses LXDM as the Display Manager in the LiveCD.

Configuration is located in `/etc/lxdm/lxdm.conf`.

Things to change:

- `[base]`
  - `session=/usr/bin/mate-session`
  - Change the default session to a suitable default (the system
    default is LXDE.
- `[display]`
  - `lang=0`
- `[userlist]`
  - `disable=1`

It seems to run `/etc/lxdm/Xsession` to set-up the session.  The default
will load files from `/etc/X11/xinit/xinitrc.d`.

After a user logs on, LXDM sources all of the following files, in order:

- `/etc/profile`
- `~/.profile`
- `/etc/xprofile`
- `~/.xprofile`

These files can be used to set session environment variables and to
start services which must set certain environment variables in order
for clients in the session to be able to use the service, like
ssh-agent.




