#!/bin/sh
#
# Alpine Linux boot selector
#
set -euf -o pipefail

mydir=$(cd "$(dirname "$0")" && pwd)

pfiles=".alpine-release apks boot efi"
ofiles="cache"

force=false

fatal() {
  echo "$@" 1>&2
  exit 1
}

is_valid() {
  local p failed=""
  local root="$1" ; shift
  for p in $pfiles
  do
    [ ! -e "$root/$p" ] && failed="$failed $p"
  done
  echo $failed
}
target_ok() {
  local p failed=""
  local root="$1" ; shift
  for p in $pfiles $ofiles
  do
    [ -e "$root/$p" ] && failed="$failed $p"
  done
  echo $failed
}

clean_up() {
  if ! $rdonly ; then
    mount -o remount,ro "$mydir" || echo "$mydir: Unable to remount ro" 1>&2
  fi
}
rdonly=true
ro_check() {
  local tmpfile=$(mktemp -p "$mydir")
  if [ -n "$tmpfile" ] ; then
    rm -f "$tmpfile"
    return
  fi
  rdonly=false
  mount -o remount,rw "$mydir" || fatal "$mydir: Unable to remount rw"
  trap clean_up EXIT
}

  
disable_system() {
  m=$(is_valid "$mydir")
  if [ -n "$m" ] ; then
    n=$(target_ok "$mydir")
    if [ -z "$n" ] ; then
      # Current system is not enabled... no need to do much
      echo "No valid system in place at the moment"
      return 0
    fi
    if $force ; then
      fatal "$mydir: does not contain a valid system (missing: $m) Use --force option"
    else
      echo "$mydir: incomplete system ($m).  Will disable!"
    fi
  fi

  if [ -f "$mydir"/.alpine-release ] ; then
    local tag=$(tr ' ' '_' < "$mydir"/.alpine-release )
    if [ -d "$mydir/$tag" ] ; then
      echo "$tag: Unable to disable (directory already exists!)"
      return 1
    fi
  else
    local c=0 prefix="_disabled."
    while [ ! -e "$mydir/$prefix$c" ]
    do
      c=$(expr $c + 1)
    done
    local tag="$prefix$c"
  fi
  ro_check
  if rmdir "$mydir/cache" >/dev/null 2>&1 ; then
    echo "$mydir/cache: empty, removed" 1>&2
  fi
  mkdir "$mydir/$tag" || fatal "$tag: Unable to create disabled directory"
  echo "Disabling $tag" 1>&2
  for v in $pfiles $ofiles
  do
    [ ! -e "$mydir/$v" ] && continue
    echo -n "$v: "
    mv "$mydir/$v" "$mydir/$tag/$v" && echo "OK" || :
  done
  m=$(target_ok "$mydir")
  [ -n "$m" ] && fatal "$tag: Unable to disable (junk: $m)"
  return 0
}
enable_system() {
  local tag="$1"
  echo "Enabling; $tag" 1>&2

  ro_check
  for v in $pfiles $ofiles
  do
    [ ! -e "$mydir/$tag/$v" ] && continue
    echo -n "$v: "
    mv "$mydir/$tag/$v" "$mydir/$v" && echo "OK" || :
  done
  if [ ! -e "$mydir/cache" ] ; then
    mkdir "$mydir/cache" && echo "cache: created"
  fi
  m=$(is_valid "$mydir")
  [ -n "$m" ] && fatal "$tag: Unable to enable (missing $m)"
  m=$(target_ok "$mydir/$tag")
  [ -n "$m" ] && fatal "$tag: Unable to clean up (left-over: $m)"
  if ! rmdir "$mydir/$tag" ; then
    fatal "$mydir/$tag: Disabling $tag in the future will be a problem"
  fi
  if [ -f "$mydir/fixup.sh" ] ; then
    ( cd "$mydir" && sh "fixup.sh" )
  fi
  return 0
}  

# Install ISO
install_iso() {
  local iso="$1" mnt=$(mktemp -d) rc=0
  if mount -r "$iso" "$mnt" ; then
    m=$(is_valid "$mnt")
    if [ -z "$m" ] ; then
      local tag=$(tr ' ' '_' < "$mnt"/.alpine-release )
      echo "$iso: Installing $tag" 1>&2
      if [ -e "$mydir/$tag" ] ; then
        if $force ; then
	  ro_check
	  echo "$mydir/$tag: Erasing existing system" 1>&2
	  rm -rf "$mydir/$tag"
	else
	  echo "$mydir/$tag: system already exists (Use --force)" 1>&2
	fi
      fi
      if [ ! -e "$mydir/$tag" ] ; then
        ro_check
	echo -n "Copying files.."
        if cp -a "$mnt" "$mydir/$tag" ; then
	  echo ".OK"
	else
	  rc=1
	fi
      fi
    else
      echo "$iso: Not valid ISO image (missing $m)" 1>&2
      rc=1
    fi
    if ! umount "$mnt" ; then
      return 1
    fi
  fi
  rmdir "$mnt" || rc=$?
  return $rc
}


####################################################################
# Main script
####################################################################
while [ $# -gt 1 ]
do
  case "$1" in
  --force|-f)
    force=true
    ;;
  --install)
    install_iso "$2"
    exit $?
    ;;
  *)
    break
    ;;
  esac
  shift
done	

if [  $# -ne 1 ] ; then
  cat <<-EOF
	Usage:

	Select an image:
	    $0 [--force] <directory>

	Disable current image:
	    $0 [--force] --disable

	Install an image:
	    $0 [--force] --instal iso-file

	EOF
  m=$(is_valid "$mydir")
  if [ -z "$m" ] ; then
    echo "$mydir: Currently using: $(cat "$mydir"/.alpine-release)"
  else
    echo "No active system in $mydir"
  fi
  q="$(mktemp -p "$mydir" 2>/dev/null)" || :
  if [ -n "$q" ] ; then
    rm -f "$q"
    echo "File-system is RW"
  else
    echo "File-system is RO"
  fi
  exit 0
fi

if [ x"$1" = x"--disable" ] ; then
  disable_system
else
  sysid=$(basename "$1")
  m=$(is_valid "$mydir/$sysid")
  [ -n "$m" ] && fatal "$sysid: not a valid system (missing: $m)"
  disable_system || exit 1
  enable_system "$sysid"
fi
