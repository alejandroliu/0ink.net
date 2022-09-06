#!/bin/sh
#
# manage RTC
#
[ $# -eq 0 ] && set - start


op_start() {
  exec >>/dev/kmsg 2>&1

  echo "Loading modules"
  modprobe i2c-dev
  modprobe rtc-ds1307
  echo "Init devfs"
  cnt=10 ; while [ ! -d /sys/class/i2c-adapter/i2c-1 ] ; do sleep 1 ; cnt=$(expr $cnt - 1) ; [ $cnt -eq 0 ] && break ;  done
  echo "Initializing device"
  echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device
  sleep 2
  hwclock --utc -s
}

op_stop() {
  exec >>/dev/kmsg 2>&1
  echo "Saving HW clock"
  hwclock --utc -w
}

case "$1" in
  start) op_start "$@" ;;
  stop) op_stop "$@" ;;
  *)
    echo "Usage; $0 {start|stop}" 1>&2
    exit 1
    ;;
esac



