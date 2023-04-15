#!/bin/sh
if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 ]]; then
  export XINITRC=/etc/X11/xinit/session
  exec startx
fi
