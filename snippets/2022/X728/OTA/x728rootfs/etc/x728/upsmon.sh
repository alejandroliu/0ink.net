#!/bin/sh
#
# X278 UPS monitor
#
gpioIO() {
  local pin=$1
  if [ $# -eq 1 ] ; then
    cat /sys/class/gpio/gpio$pin/value
  else
    echo "$2" > /sys/class/gpio/gpio$pin/value
  fi
}

gpioInit() {
  local name="$1" pin="$2" dir="$3"

  [ ! -d /sys/class/gpio/gpio$pin ] && echo "$pin" > /sys/class/gpio/export
  echo $dir > /sys/class/gpio/gpio$pin/direction

  eval "gpio${name}() { gpioIO $pin \"\$@\" ; }"
}
ticks() {
  echo $(date +%s)$(date +%N | cut -c-2)
}

beep() {
  local len="$1" ; shift

  gpioBUZZER 1
  sleep "$len"
  gpioBUZZER 0

  [ $# -eq 0 ] && return

  local repeat="$1" idle
  [ $# -gt 1 ] && idle="$2" || idle="$len"

  while [ $repeat -gt 1 ]
  do
    repeat=$(expr $repeat - 1)
    sleep "$idle"
    gpioBUZZER 1
    sleep "$len"
    gpioBUZZER 0
  done
}

set -euf #-o pipefail

gpioInit SHUTDOWN 5 in
gpioInit PLD 6 in
gpioInit BOOT 12 out
gpioInit BUZZER 20 out
gpioInit BUTTON 26 out

gpioBOOT 1  # Do this to enable reading SHUTDOWN pin (#5)

POLL_TIME=0.2
READV_CMD=x728batt

if type $READV_CMD >/dev/null 2>&1 ; then
  READ_V=true
else
  READ_V=false
fi

AC_LOST_SLEEP=60
AC_LOST_START=0
AC_LOST_MSG=true
SHUTDOWN_STATE=$(gpioSHUTDOWN)

while true ; do
  shutdown=$(gpioSHUTDOWN)
  if [ $shutdown -ne $SHUTDOWN_STATE ] ; then
    SHUTDOWN_STATE=$shutdown
    if [ $shutdown -eq 1 ] ; then
      echo "Shutdown via HW button" | tee /dev/kmsg
      beep 0.1 2 0.3
      poweroff
      exit
    else
      # Released... We are not able to reliably detect this!
      echo "Shutdown HW button released" | tee /dev/kmsg
      beep 0.1
    fi
  fi

  ac_power=$(gpioPLD)
  if [ $ac_power -eq 1 ] ; then
    # A/C Power loss..
    if $READ_V ; then
      # We are able to read Battery status... just inform
      if [ $(expr $(date +%s) - $AC_LOST_START) -gt $AC_LOST_SLEEP ] ; then
        beep 0.5
        AC_LOST_START=$(date +%s)
      fi
      if $AC_LOST_MSG ; then
        echo "A/C Power lost" | tee /dev/kmsg
	AC_LOST_MSG=false
      fi

      # Read voltage
      if [ $($READV_CMD | awk '$1 == "Voltage" { print int($2 * 100); }') -lt 300 ] ; then
        echo "Battery LOW, initiating shutdown" | tee /dev/kmsg
        beep 0.1 3 0.2
	sleep 10
	poweroff
	exit
      fi
    else
      # Lost AC Power and can't check battery status
      # Initiate graceful shutdown
      echo "A/C Power lost -- intiating shutdown" | tee /dev/kmsg
      beep 0.1 3 0.2
      sleep 10
      poweroff
      exit
    fi
  else
    # A/C Power restored
    if ! $AC_LOST_MSG ; then
      echo "A/C Power OK" | tee /dev/kmsg
      AC_LOST_MSG=true
      beep 0.1 3
    fi
    AC_LOST_START=0
  fi

  sleep $POLL_TIME
done

