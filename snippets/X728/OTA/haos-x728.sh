#!/bin/sh
#
# Hack the haos image to include my stuff...
#
# Create a custom handler so that RAUC OTA updates include
# customizations
#
set -euf -o pipefail
die() {
  echo "$@" 1>&2
  exit $1
}


usage() {
  cat 1>&2 <<-_EOV_
	Usage: $0 [--ssh] {img} {rootfs}

	Options:
	  --ssh : Enable ssh
	_EOV_
  exit 1
}
( type sqfs2tar && type gensquashfs ) || die 21 "Need to install squashfs-tools-ng"
[ $(id -u) -ne 0 ] && die 22 "Must be run as root"

[ $# -eq 0 ] && usage

summarize() {
 while read -r L
  do
    printf '\r'
    echo -n "$L"
    printf '\033[K'
  done
  printf '\rDone\033[K\r\n'
}
gsqfsout() {
  while read -r L
  do
    if (echo "$L" | grep -q packing) ; then
      echo "$L"
    else
      exec 1>&2
      echo "$L"
      exec cat
    fi
  done
}


ssh=/
backup=false

while [ $# -gt 0 ] ; do
  case "$1" in
    --ssh) ssh=/ ;;
    --ssh=*) ssh=${1#--ssh=} ;;
    --no-ssh) ssh= ;;
    --backup) backup=true ;;
    *) break ;;
  esac
  shift
done

[ $# -ne 2 ] && usage

img="$1"
rootfs="$(echo "$2" | sed -e s'!/*$!!')"

$backup && cp -av "$img" "$img~"
if (echo "$img" | grep -q '\.xz$' ) ; then
  xz -d "$img"
  img=$(echo "$img" | sed -e 's/\.xz$//')
fi

w=$(mktemp -d) ; trap "umount $w/mnt || : ; rm -rf $w; kpartx -dv \$img" EXIT
mkdir $w/mnt
kpartx -av "$img"

bootfs=/dev/loop0p1
mount -o loop $bootfs $w/mnt
if [ -f $w/mnt/config.txt ] ; then
  echo "Enable i2c bus"
  (
    echo '[all]'
    echo 'dtparam=i2c_arm=on'
  ) | tee -a $w/mnt/config.txt | summarize
fi
if [ -n "$ssh" ]; then
  auth_keys=""
  if [ x"$ssh" = x"/" ] ; then
    if [ -n "${SUDO_USER:-}" ] ; then
      userhome=$(getent passwd $SUDO_USER | cut -d: -f6)
      if [ -f "$userhome/.ssh/authorized_keys" ] ; then
        auth_keys="$userhome/.ssh/authorized_keys"
      fi
    fi
    if [ -z "$auth_keys" ] && [ -f "$HOME/.ssh/authorized_keys" ] ; then
      auth_keys="$HOME/.ssh/authorized_keys"
    fi
  elif [ -f "$ssh" ] ; then
    auth_keys="$ssh"
  elif [ -f "$ssh/.ssh/authorized_keys" ] ; then
    auth_keys="$ssh/.ssh/authorized_keys"
  elif [ -f "$ssh/authorized_keys" ] ; then
    auth_keys="$ssh/authorized_keys"
  fi
  if [ -z "$auth_keys" ] ; then
    echo "Unable to enable SSH as no authorized_keys found"
  else
    echo "Enabling SSH"
    mkdir -p $w/mnt/CONFIG
    cp "$auth_keys" $w/mnt/CONFIG
  fi
fi
umount $w/mnt


systemfs=/dev/loop0p3
mkdir -p $w/rootfs
sqfs2tar $systemfs | tar -C $w/rootfs -xvf - 2>&1 | summarize

# add the post-install handler
# sed -i -e '/^\[system\]$/a post-install=/lib/rauc/post-install'
( tee -a $w/rootfs/etc/rauc/system.conf | summarize ) <<-_EOF_
	[handlers]
	post-install=/lib/rauc/post-install
	_EOF_

if [ -f "$rootfs" ] ; then
  # So this is a tarball
  mkdir -p "$w/srcfs"
  tar -C "$w/srcfs" -xvf "$rootfs" 2>&1 | summarize
  rootfs="$w/srcfs"
fi

find $rootfs '(' -type f -o -type l ')'| sed -e "s!$rootfs/!!" | tee $w/rootfs/etc/rauc/custom-files | (while read fpath
do
  dir=$(dirname "$fpath")
  mkdir -vp "$w/rootfs/$dir"
  cp -av "$rootfs/$fpath" "$w/rootfs/$dir" 2>&1
done) | summarize
gensquashfs -D "$w/rootfs" $w/new-rootfs.img 2>&1 | gsqfsout | summarize
dd bs=64k if=$w/new-rootfs.img of=$systemfs
