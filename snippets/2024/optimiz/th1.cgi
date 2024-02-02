#!/bin/sh

gen_cache_id() {
  local j
  echo -n 'cache'
  for j in is_ext is_int is_tool is_toolint
  do
    $j && echo -n 1 || echo -n 0
  done
  echo .md
}
valid_cache() {
  local cf="$1"
  #set -x
  #ls -lh "$cf" 1>&2
  #ls -lh "$doc" 1>&2
  [ ! -f "$cf" ] && return 1
  [ "$cf" -ot "$doc" ] && return 1
  # [ "$doc" -nt "$cf" ] && return 1
  return 0
}



txmenu() {
  local cache_id=$(gen_cache_id)
  if valid_cache data-v4/cache/$cache_id ; then
    cat data-v4/cache/$cache_id
  else
    _txmenu | (umask 002 ; tee data-v4/cache/$cache_id )
  fi
}

_txmenu() {
  local HM=true APP=true
  sed \
    -e 's/#.*$//' \
    -e 's/^\([_A-Za-z0-9]\)/1 \1/' \
    -e 's/^[ \t][ \t]*/2 /' | grep -v '^$' | while read T ARGS
  do
    [ -z "$T" ] && continue
    [ -z "$ARGS" ] && continue
    set - '' ; shift #; set -x
    if (echo "$ARGS" | grep -q '>') ; then
      local i=1
      while [ -n "$(echo "$ARGS" | cut -d'>' -f$i-)" ] ; do
	set - "$@" "$(echo "$ARGS" | cut -d'>' -f$i | xargs)"
	i=$(expr $i + 1)
      done
    else
      set - "$(echo $ARGS | xargs)"
    fi

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
      echo "- [$1]($2)"
      [ $# -gt 3 ] && [ -n "$4" ] && echo "$4<br/>"
      ;;
    2)
      [ $# -eq 0 ] && continue
      $APP || continue
      [ $# -gt 2 ] && ! is_$3 && continue
      elem2o='<span style="font-size: x-small">['
      elem2c=']</span>'
      echo "  ${elem2o}[$1]($2)${elem2c}"
      ;;
    *) echo 'SYN ERROR' ;;
    esac
  done
}
