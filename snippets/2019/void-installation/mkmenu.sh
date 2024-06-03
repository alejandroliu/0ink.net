#!/bin/bash
#
# Simple boot menu generator
#
# Updates a REFIND and SYSLINUX menus
#
set -euf -o pipefail

bootdir=$(cd $(dirname $0) && pwd)
[ -z "$bootdir" ] &&  exit 1

read_cmdline() {
  sed -e 's/#.*$//' < "$1" | xargs
}

if [ -f "$bootdir/cmdline" ] ; then
  def_cmdline="$(read_cmdline $bootdir/cmdline)"
else
  def_cmdline="auto"
fi

find_kernels() {
  find "$bootdir" -maxdepth 1 -type f -name 'vmlinuz*' | (while read k
  do
    kver=$(basename "$k" | cut -d- -f2-)
    [ -f "$bootdir/initramfs-$kver.img" ] || continue
    echo "$kver"
  done) | sort -r -V
}

find_kernels

if [ -d "$bootdir/EFI/BOOT" ] ; then
  echo "Creating REFIND menu"
  (
    echo "scanfor manual"
    echo "timeout 3"
    echo "default_selection 1"

    for kver in $(find_kernels)
    do
      date=$(date --reference="$bootdir/vmlinuz-$kver" +"%Y-%m-%d")

      echo "menuentry \"linux-$kver ($date)\" {"
      echo "  loader /vmlinuz-$kver"
      echo "  initrd /initramfs-$kver.img"
      if [ -f "$bootdir/cmdline-$kver" ] ; then
        echo "  options \"$(cat "$bootdir/cmdline-$kver")\""
      else
        echo "  options \"$def_cmdline\""
      fi
      echo "}"
    done
  ) > "$bootdir/EFI/BOOT/refind.conf"
fi

echo "Creating syslinux menu"
(
  echo "DEFAULT linux-$(find_kernels | head -1)"
  echo "TIMEOUT 30"

  for kver in $(find_kernels)
  do
    date=$(date --reference="$bootdir/vmlinuz-$kver" +"%Y-%m-%d")

    echo "LABEL linux-$kver ($date)"
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

