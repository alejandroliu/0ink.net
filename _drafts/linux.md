---
title: Linux Post Install tasks
---

These tips are for [void linux][void] as that is the distro
I am using nowadays.

* * *

Additional software (Tested on void linux):

Tip: use `sed -e 's/#.*$//'` to strip comments!

<script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/linux-post-install/void-swlist.txt?footer=minimal"></script>

## System backups

For [void linux][void] I prefer to re-install instead to do a full
backup.  A few selected files are backed-up.  This is done with this
script:

<script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/linux-post-install/rsvault.sh?footer=minimal"></script>

Install:

```
wget -O/usr/local/sbin/rsvault https://github.com/alejandroliu/0ink.net/raw/master/snippets/linux-post-install/rsvault.sh
chmod 755 /usr/local/sbin/rsvault
printf '#!/bin/sh\n/usr/local/sbin/rsvault\n' | tee /etc/cron.daily/rsvault
chmod 755 /etc/cron.daily/rsvault
mkdir /etc/rsync.vault
printf 'rsync_passwd=<PASSWORD>\nrsync_host="vms3"\n' > /etc/rsync.cfg
chmod 600 /etc/rsync.cfg
```

Then create hardlinks to the chosen files to `/etc/rsvault`.  Possible
candidates:

- `/etc/crypttab`
- `/crypto_keyfile.bin`
- `/etc/hosts` #: if using for ad blocking

For full backups, this can be used:

<script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/linux-post-install/os-backup.sh?footer=minimal"></script>


## Identd server

I am using this for my own systems.



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

## LXDM specifics

MATE under Void Linux uses [LXDM][lxdm] as the Display Manager in the LiveCD.

Configuration is located in `/etc/lxdm/lxdm.conf`.

Things to change:

- `[base]`
  - `session=/usr/bin/mate-session`
  - Change the default session to a suitable default (the system
    default is LXDE).
- `[display]`
  - `lang=0`
- `[userlist]`
  - `disable=1`

After the user logs on, [lxdm][lxdm] seems to run `/etc/lxdm/Xsession`
to set-up the session.  Amongst other things, [lxdm][lxdm] sources
all of the following files, in order:

- `/etc/profile`
- `~/.profile`
- `/etc/xprofile`
- `~/.xprofile`

These files can be used to set session environment variables and to
start services which must set certain environment variables in order
for clients in the session to be able to use the service, like
ssh-agent.

 [void]: https://voidlinux.org "Void Linux"
 [lxdm]: https://wiki.lxde.org/en/LXDM "LXDM Display Manager"
