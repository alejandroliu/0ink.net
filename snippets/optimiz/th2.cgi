#!/bin/sh

_txmenu() {
  local HM=true APP=true T ARGS oIFS="$IFS"
  local  \
	elem2o='<span style="background-color: #d0e0e0; font-size: x-small">[' \
	elem2c=']</span>'

  sed \
    -e 's/#.*$//' \
    -e 's/^\([_A-Za-z0-9]\)/1 \1/' \
    -e 's/^[ \t][ \t]*/2 /' \
    -e 's/[ 	]*>[ 	]*/>/g' \
    | grep -v '^$' | while read T ARGS
  do
    [ -z "$T" ] && continue
    [ -z "$ARGS" ] && continue
    set - '' ; shift

    case "$ARGS" in
    *\>*)
      IFS=">" ; set - $ARGS; IFS="$oIFS"
      ;;
    *)
      set - $ARGS ; set - "$*"
      ;;
    esac

    case "$T" in
    =)
      [ $# -eq 0 ] && continue
      if [ $# -gt 1 ] && ! is_$2 ; then
        HM=false
	continue
      fi
      echo ''
      echo "# $1"
      echo ''
      HM=true
      ;;
    1)
      [ $# -eq 0 ] && continue
      if ! $HM ; then
        APP=false
	continue
      fi
      if [ $# -gt 2 ] && [ -n "$3" ] && ! is_$3 ; then
        APP=false
	continue
      fi
      APP=true
      if [ $# -gt 3 ] && [ -n "$4" ]; then
	echo "- [$1]($2) $4<br/>"
      else
	echo "- [$1]($2)"
      fi
      ;;
    2)
      [ $# -eq 0 ] && continue
      $APP || continue
      [ $# -gt 2 ] && ! is_$3 && continue
      echo "  ${elem2o}[$1]($2)${elem2c}"
      ;;
    *) echo 'SYN ERROR' ;;
    esac

  done
}

