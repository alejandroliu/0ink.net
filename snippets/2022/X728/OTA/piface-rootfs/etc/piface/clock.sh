#!/bin/sh
#
# manage RTC
#
[ $# -eq 0 ] && set - start


op_start() {
  local i=1
  exec >>/dev/kmsg 2>&1

  echo "Loading i2c-dev"
  modprobe i2c-dev
  cnt=10 ; while [ ! -d /sys/class/i2c-adapter/i2c-$i ] ; do sleep 1 ; cnt=$(expr $cnt - 1) ; [ $cnt -eq 0 ] && break ;  done

  # Calibrate the clock (default: 0x47). See datasheet for MCP7940N
  echo "Calibrate clock"
  i2cset -y $i 0x6f 0x08 0x47

  echo "Loading mcp7941x driver"
  modprobe i2c:mcp7941x

  echo "Initializing mcp7941x sysfs driver"
  echo mcp7941x 0x6f > /sys/class/i2c-adapter/i2c-$i/new_device
  sleep 2
  echo "Sync hw clock"
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



