#!/bin/sh
#
# To be run from the session script (before desktop environment is
# launched)
#
(
  if [ -f $HOME/.xbindkeysrc ] ; then
    xbindkeys -n -f $HOME/.xbindkeysrc &
  fi
  # sleep 5 # Give chance to desktop environment and user short-cuts
  exec xbindkeys -n -f /etc/X11/xbindkeysrc
) &
