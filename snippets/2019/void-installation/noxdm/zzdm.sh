#!/bin/sh
if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 && $(id -u) -gt 100 && -d "$HOME" ]]; then
  export XINITRC=/etc/X11/Xsession
  . $HOME/.bashrc # Make sure PATH is set-up
  clear
  XCLIENT_OPTS=""
  XSERVER_OPTS=""
  [ -f /etc/X11/zzdm-opts.sh ] && . /etc/X11/zzdm-opts.sh
  exec startx $XCLIENT_OPTS -- $XSERVER_OPTS
fi
