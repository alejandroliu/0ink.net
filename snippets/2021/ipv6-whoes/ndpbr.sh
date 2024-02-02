#!/bin/sh
#
# NDPBR : Network Discovery Protocol Bridge
#
set -euf -o pipefail

enable_proxy_ndp() {
  local enable=1

  if [ $# -gt 0 ] && [ x"$1" = x"--disable" ] ; then
    enable=0
    shift
  fi

  local iface
  for iface in "$@"
  do
    sysctl -w net.ipv6.conf.$iface.proxy_ndp=$enable || return 1
  done
  return 0
}

awk_get_routes() {
  [ $# -eq 0 ] && set - "%s,%s"
  ip -6 route | awk '$2 == "dev" && $1 ~ /^[0-9a-f][0-9a-f][0-9a-f][0-9a-f]:/ && !($1 ~ /^fe80:/) && !($1 ~ /\//) {
    printf "'"$*"'\n",$1,$3;
  }'
}

awk_get_entries() {
  [ $# -eq 0 ] && set - "%s,%s"
  ip -6 neigh show proxy | awk '$2 == "dev" && $4 == "proxy" {
    printf "'"$*"'\n",$1,$3;
  }'
}

awk_iflst() {
  local fmt='iflst["%s"] = 1' i
  while [ $# -gt 0 ]
  do
    case "$1" in
      --fmt=*) fmt=${1#--fmt=} ;;
      *) break
    esac
    shift
  done
  for i in "$@"
  do
    printf "$fmt"'\n' $i
  done
}


add_entry() {
  local addr="$1" iface="$2" ; shift 2
  [ x"$1" = x"->" ] && shift

  $verbose Adding entry for "$addr"%"$iface"
  # Add a specific route to this address...
  ip -6 route add "$addr"/128 dev "$iface"

  # Proxy NDP to the other interfaces...
  local i
  for i in "$@"
  do
    [ "$i" = "$iface" ] && continue
    ip -6 neigh add proxy "$addr" dev "$i"
  done
}

expire_entries() {
  local addr rtdev prxlst prxdev pingtest=true

  if [ $# -gt 0 ] && [ x"$1" = x"--flush" ] ; then
    pingtest=false
    shift
  fi

  ip -6 neigh show proxy | awk 'BEGIN {
    '"$(awk_iflst "$@")"'
  }
  {
    if ($3 in iflst) {
      if ($1 in pe) {
	pe[$1] = pe[$1] " " $3;
      } else {
	pe[$1] = $3;
      }
    }
  }
  END {
    for (ip6 in pe) {
      print ip6 "\t" pe[ip6];
    }
  }' | while read addr prxlst
  do
    if $pingtest ; then
      ping -c 1 $addr >/dev/null 2>&1 && continue
    fi
    # ping failed, so this proxy entry is not valid anymore...
    $verbose "Flushing entry $addr ($prxlst)"
    for prxdev in $prxlst
    do
      ip -6 neigh del proxy "$addr" dev "$prxdev"
    done
    ip -6 r \
	| awk '$1 == "'"$addr"'" && $2 == "dev" { print $3 }' \
	| while read dev
	do
	  ip -6 route del "$addr" dev "$dev"
	done
  done
}

preload_neighbors() {
  ip -6 neigh | awk '
    BEGIN {
    '"$(awk_get_entries 'pe[\"%s\"]=\"%s\";')"'
    '"$(awk_iflst "$@")"'
    }
    $2 == "dev" && $1 ~ /^[0-9a-f][0-9a-f][0-9a-f][0-9a-f]:/ && !($1 ~ /^fe80:/) && $NF != "FAILED" && $(NF-1) != "router" {
      if (!($1 in pe) && ($3 in iflst)) {
	print $1,$3;
      }
    }' | while read addr ifdev
    do
      add_entry "$addr" "$ifdev" '->' "$@"
    done
}

monitor_neighbors() {
  (
    sh -c 'echo $PPID' >> $pidfile
    exec ip -6 monitor neigh
  ) | awk '
    BEGIN {
    '"$(awk_iflst "$@")"'
    }
    $2 == "dev" && $1 ~ /^[0-9a-f][0-9a-f][0-9a-f][0-9a-f]:/ && !($1 ~ /^fe80:/) && $NF == "REACHABLE" && $(NF-1) != "router" {
      print $1,$3;
    }
  ' | while read addr iface
  do
    dup=$(ip -6 neigh show proxy | awk '$1 == "'"$addr"'" && $2 != "'"$iface"'" ')
    [ -n "$dup" ] && continue
    add_entry "$addr" "$iface" '->' "$@"
  done
}


show_entries() {
  local addr rtdev prxlst prxdev pingtest=false

  if [ $# -gt 0 ] && [ x"$1" = x"--ping" ] ; then
    pingtest=true
    shift
  fi

  ip -6 neigh show proxy | awk 'BEGIN {
    '"$(awk_get_routes 'rt[\"%s\"]=\"%s\";')"'
  }
  {
    if ($1 in rt) {
      if ($1 in pe) {
	pe[$1] = pe[$1] " " $3;
      } else {
	pe[$1] = rt[$1] " " $3;
      }
    }
  }
  END {
    for (ip6 in pe) {
      print ip6 "\t" pe[ip6];
    }
  }' | while read addr rtdev prxlst
  do
    echo -n "$addr $rtdev -> $prxlst"
    if $pingtest ; then
      rt=$(
	ping -I $rtdev -c 1 $addr 2>&1 | grep round-trip | cut -d/ -f4
      ) || :
      if [ -n "$rt" ] ; then
	echo -n " (RTT $rt ms)"
      else
        echo -n " (FAILED)"
      fi
    fi
    echo ''
  done
}

shutdown_proxy() {
  echo "SHUTTING DOWN: $*"
  expire_entries --flush "$@"
  enable_proxy_ndp --disable "$@"
}

expire_timer() {
  local wait=600
  while [ $# -gt 0 ]
  do
    case "$1" in
      --wait=*) wait=${1#--wait=} ;;
      *) break
    esac
    shift
  done

  while :
  do
    (
      oldpid=$(cat $pidfile)
      newpid=""
      for i in $oldpid
      do
	[ -d /proc/$i ] && newpid="$(printf "%s\n%s" "$newpid" "$i")"
      done
      printf "%s\n%s\n" "$newpid" "$(sh -c 'echo $PPID')" > $pidfile
      exec sleep $wait
    ) || :
    echo "EXPIRING $*"
    expire_entries "$@"
  done
}

usage() {
      cat <<-_EOF_
	Usage:
	  $0 [-v|-l] run|show [options]

	* -v|--verbose : show what it is doing
	* -l|--syslog : log messages to syslog
	* --pidfile=pidfile

	Sub commands:

	* run [iflist] : bridge interfaces
	* show [--ping]: show proxy entries
	* flush : flush Linux kernel ndp entries
	* kill : kill daemon
	_EOF_
      exit 0
}

main() {
  verbose=":"
  pidfile="/run/ndpbr.pid"

  while [ $# -gt 0 ]
  do
    case "$1" in
    -v|--verbose)
      verbose="echo"
      ;;
    -l|--syslog)
      verbose="logger -t $(basename $0)"
      ;;
    --pidfile=*)
      pidfile=${1#--pidfile=}
      ;;
    *)
      break
      ;;
    esac
    shift
  done

  [ $# -eq 0 ] && usage

  case "$1" in
    run)
      shift

      iflist="$*"
      enable_proxy_ndp $iflist || exit 1
      preload_neighbors $iflist
      expire_timer --wait=3600 $iflist &
      expire_pid=$!
      monitor_neighbors $iflist &
      monitor_pid=$!
      cat >$pidfile <<-_EOF_
	$$
	$expire_pid
	$monitor_pid
	_EOF_
      $verbose "Started..."
      wait || :
      shutdown_proxy $iflist
      rm -f $pidfile
      ;;
    kill)
      kill $(cat $pidfile)
      ;;
    flush)
      expire_entries --flush $(grep : /proc/net/dev | cut -d: -f1 | xargs)
      enable_proxy_ndp --disable $(grep : /proc/net/dev | cut -d: -f1 | xargs)
      ;;
    show)
      shift ;show_entries "$@"
      exit $?
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
