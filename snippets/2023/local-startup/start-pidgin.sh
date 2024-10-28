#!/bin/sh
#
# Start pidgin and send it to the tray!
#

wait_win() {
  local t=120
  while [ $t -gt 0 ]
  do
    t=$(expr $t - 1)
    (wmctrl -l | grep -q "$*") && return 0
    sleep 0.1
  done
  return 1
}


( wait_win "Buddy List" && wmctrl -c "Buddy List" ) &
exec pidgin
