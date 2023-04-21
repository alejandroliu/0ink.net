#!/bin/sh
if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 && $(id -u) -gt 100 ]]; then
  export XINITRC=/etc/X11/Xsession
  . $HOME/.bashrc # Make sure PATH is set-up
  clear
  exec startx
fi
