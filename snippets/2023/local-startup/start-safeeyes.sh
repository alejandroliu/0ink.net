#!/bin/sh
#
# Check if safeeyes is *NOT* running...
#

find_safeeyes() {
  local out=$(
      ps axu | awk -vUSER=$(id -un) '
	$1 == USER && $11 ~ /python/ && $12 ~ /safeeyes/
      '
  )
  [ -n "$out" ]
}

if find_safeeyes ; then
  echo "Safeeyes already running"
else
  safeeyes &
  echo "SafeEyes running as $!"
fi



