#!/bin/sh
count=2000

is_ext() { return 1; }
is_tool() { return 1; }
if is_ext ; then
  is_int() { return 1; }
else
  is_int() { return 0; }
fi
if is_tool || is_int ; then
  is_toolint() { return 0; }
else
  is_toolint() { return 1; }
fi


while [ $# -gt 0 ]
do
  case "$1" in
  -1|--no-count) count=0 ;;
  --count=*) count=${1#--count=} ;;
  *) break ;;
  esac
  shift
done

if [ $# -eq 0 ] ; then
  echo "must specify 1 or 2"
  exit 1
fi

case "$1" in
1|2)
  . "$(dirname "$0")/th$1.cgi"
  ;;
*)
  echo "Unknown test: $1"
  exit 2
  ;;
esac

if [ $count -eq 0 ] ; then
  _txmenu < input.txt
  exit
fi


x=$count
while [ $x -gt 0 ]
do
  x=$(expr $x - 1) || :
  _txmenu < input.txt > /dev/null
done

  #~ _txmenu < input.txt

