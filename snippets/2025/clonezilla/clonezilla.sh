#!/bin/sh
#
# Create REFIND image
#
set -euf -o pipefail

main() {
  if [ $# -eq 0 ] ; then
    cat 1>&2 <<-_EOF_
	Usage: $0 [clonezilla-zip] [img] [size]
	_EOF_
    exit 1
  fi
  if [ $(id -u) -ne 0 ] ; then
    echo "Must be run as root" 1>&2
    exit 1
  fi
  local zip="$1" img="$2"
  [ ! -b "$img" ] && local sz="$3"
  local label="$(printf "EFI%4d" $(expr $RANDOM % 10000))"
  local t=$(mktemp -d) rc=0
  local blocksize=4096
  (
    [ ! -b "$img" ] && fallocate -l "$sz" "$img"
    sfdisk --wipe-partitions always "$img" <<-_EOF_
	label: gpt
	;500M;U;*
	;;L;
	_EOF_
    if [ -b "$img" ] ;then
      lodev="$img"
    else
      partx=$(kpartx -av "$img")
      lodev=/dev/mapper/$(echo "$partx" | awk '$1 == "add" && $2 == "map" { print substr($3,0,length($3)-1); exit; }')
      if [ -z "$lodev" ] ; then
	echo "Unable to identify Loopback device" 1>&2
	return 1
      fi
    fi

    mkfs.vfat \
	-F 32 \
	-n "$label" \
	-v "${lodev}1"
    mkfs.ext4 \
      -b $blocksize \
      -E stride=16,stripe-width=16 \
      -i 8192 \
      -m 0 \
      -L data \
      -O ^has_journal \
      -v ${lodev}2

    mount -t vfat ${lodev}1 $t
    unzip -d "$t" "$zip"

  ) || rc=$?
  umount $t || :
  [ ! -b "$img" ] && kpartx -dv "$img" || :

  [ $rc -ne 0 ] && rm -fv "$img"
  rm -rf "$t"
  exit $rc
}

main clonezilla-live-3.2.2-5-amd64.zip cz.img 32G
#~ main clonezilla-live-3.2.2-5-amd64.zip /dev/sdd

