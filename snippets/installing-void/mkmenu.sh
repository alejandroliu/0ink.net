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

find_kernels

(
  echo "scanfor manual"
  echo "timeout 3"
  echo "default_selection 1"

  for kver in $(find_kernels)
  do
    echo "menuentry \"linux-$kver\" {"
    echo "  loader /vmlinuz-$kver"
    echo "  initrd /initramfs-$kver.img"
    if [ -f "$bootdir/cmdline-$kver" ] ; then
      echo "  options" \"$(cat "$bootdir/cmdline-$kver")\"
    else
      echo "  options" \"$def_cmdline\"
    fi
    echo "}"
  done
) > "$bootdir/EFI/BOOT/refind.conf"


