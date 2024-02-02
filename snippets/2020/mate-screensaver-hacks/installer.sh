#!/bin/bash
#
# Installer
#

runner() {
  if [ $# -eq 0 ] ; then
    cat 1>&2 <<-_EOF_
	Usage:
	  env [XSCREENSAVER_HACKDIR=/path] XSCREENSAVER_WINDOW=window-id "$0" {hack}
	_EOF_
    exit 1
  fi

  if [ -n "${XSCREENSAVER_HACKDIR:-}" ] ; then
    hacksdir="${XSCREENSAVER_HACKDIR}"
  else
    hacksdir=/usr/libexec/xscreensaver
  fi

  hack="$1" ; shift

  if [ ! -x "$hacksdir/$hack" ] ; then
    echo "$hack: not found" 1>&2
    exit 2
  fi

  # ( date ; echo "$@" ; env) > /tmp/grav.log
  if [ -n "${XSCREENSAVER_WINDOW:-}" ] ; then
    set - -window-id $(printf "%d" $XSCREENSAVER_WINDOW) "$@"
  fi
  exec "$hacksdir"/"$hack" "$@"
}

blacklisted() {
  case "$1" in
  glitchpeg|ljlatest|vidwhacker)
    return 0
    ;;
  webcollage*)
    return 0
    ;;
  esac
  return 1
}

op_hacks() {
  # List available hacks
  enabled="echo" ; disabled="echo"
  
  while [ $# -gt 0 ]
  do
    case "$1" in
    --enabled|-e)
      enabled="echo"
      disabled=":"
      ;;
    --disabled|-d)
      enabled=":"
      disabled="echo"
      ;;
    --all|-a)
      enabled="echo"
      disabled="echo"
      ;;
    *)
      break
    esac
    shift
  done
  
  ls -1 "$hacksdir" | while read h
  do
    if [ -e "$desktopdir/xscr-$h.desktop" ] ; then
      status="[ENABLED]"
      output="$enabled"
    else
      if blacklisted "$h" ; then
      	status="[BLACKLISTED]"
      else
      	status="[DISABLED]"
      fi
      output="$disabled"
    fi
    "$output" "$h:	$status"
  done
}

op_enable() {
  if [ $# -eq 0 ] ; then
    echo "Please specify hacks to enable or [--all] to enable all" 1>&2
    exit 1
  fi
  if [ x"$1" = x"--all" ] ; then
    set - $(ls -1 "$hacksdir")
  fi

  runner=/usr/libexec/mate-screensaver/xscreensaver-hack
  if [ ! -x "$runner" ] ; then
    if ! (
      exec > "$runner" || exit 1
      echo "$!/bin/sh"
      declare -f runner
      echo 'runner "$@"'
      chmod 755 "$runner" || exit 1
    ) ; then
      echo "Unable to install $runner" 1>&2
      exit 2
    fi
  fi

  error=0
  for hack in "$@"
  do
    if [ ! -x "$hacksdir/$hack" ] ; then
      echo "$hack: does not exist" 1>&2
      error=1
      continue
    fi
    if blacklisted "$hack" ; then
      echo "$hack: is blacklisted" 1>&2
      continue
    fi
    if [ -e "$desktopdir/xscr-$hack.desktop" ] ; then
      # Already enabled
      continue
    fi
    echo -n "$hack: " 1>&2
    if (
      cat >"$desktopdir/xscr-$hack.desktop" <<-_EOF_
	# XSCREENSAVER-HACK
	[Desktop Entry]
	Name=$hack
	Comment=XScreenSaver Hack (https://www.jwz.org/xscreensaver/)
	Exec=$runner $hack
	TryExec=$runner
	StartupNotify=false
	Terminal=false
	Type=Application
	Categories=Screensaver;
	# Translators: Search terms to find this application. Do NOT translate or localize the semicolons! The list MUST also end with a semicolon!
	Keywords=MATE;screensaver;XScreenSaver
	OnlyShowIn=MATE;
	_EOF_
    ) ; then
      echo "enabled" 1>&2
    else
      error=1
    fi
  done
  exit $error
}

op_disable() {
  if [ $# -eq 0 ] ; then
    echo "Please specify hacks to disable or [--all] to enable all" 1>&2
    exit 1
  fi
  if [ x"$1" = x"--all" ] ; then
    set - $(ls -1 "$hacksdir")
  fi
  error=0
  for hack in "$@"
  do
    if [ ! -x "$hacksdir/$hack" ] ; then
      echo "$hack: does not exist" 1>&2
      error=1
      continue
    fi
    if [ ! -e "$desktopdir/xscr-$hack.desktop" ] ; then
      # Already disabled
      continue
    fi
    echo -n "$hack: " 1>&2
    if rm -f "$desktopdir/xscr-$hack.desktop" ; then
      echo "disabled" 1>&2
    else
      error=1
    fi
  done
  exit $error
}

hacksdir="/usr/libexec/xscreensaver"
desktopdir="/usr/share/applications/screensavers"

while [ $# -gt 0 ] ; do
  case "$1" in
  --hacks=*)
    hacksdir=${1#--hacks=}
    ;;
  --desktop=*)
    desktopdir=${1#--desktop=}
    ;;
  *)
    break
    ;;
  esac
  shift
done

if [ $# -eq 0 ] ; then
  cat 1>&2 <<-_EOF_
	Usage:
	
	$0 hacks
	    List available hacks
	$0 enable [--all|hacks]
	    Enable xscreensaver hacks
	$0 disable [--all|hacks]
	    Disable xscreensaver hacks
	_EOF_
  exit 1
fi

cmd="$1" ; shift
op_${cmd} "$@"

