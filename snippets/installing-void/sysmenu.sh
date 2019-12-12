#!/bin/bash
#
# Simple boot menu generator
#
set -euf -o pipefail

bootdir=$(cd $(dirname $0) && pwd)
[ -z "$bootdir" ] &&  exit 1

if [ -f "$bootdir/cmdline" ] ; then
  def_cmdline="$(cat $bootdir/cmdline)"
else
  def_cmdline="auto"
fi

find_kernels() {
  find "$bootdir" -maxdepth 1 -type f -name 'vmlinuz*' | (while read k
  do
    kver=$(basename "$k" | cut -d- -f2-)
    [ -f "$bootdir/initramfs-$kver.img" ] || continue
    echo "$kver"
  done) | sort -r
}

echo "Creating syslinux menu"
find_kernels

(
  echo "DEFAULT linux-$(find_kernels | head -1)"
  echo "TIMEOUT 30"

  for kver in $(find_kernels)
  do
    echo "LABEL linux-$kver"
    echo "  KERNEL vmlinuz-$kver"
    echo "  INITRD initramfs-$kver.img"
    if [ -f "$bootdir/cmdline-$kver" ] ; then
      echo "  APPEND $(cat "$bootdir/cmdline-$kver")"
    else
      echo "  APPEND $def_cmdline"
    fi
    echo ""
  done
) > "$bootdir/syslinux.cfg"


