#!/bin/sh
#
# Enter an image...
#
# Use this to explore the contents of the image before writing to SD
# card.
#
set -euf -o pipefail
die() {
  echo "$@" 1>&2
  exit $1
}

[ $# -ne 2 ] && die 1 "Usage: $0 {img} {part}"
img="$1"
part="$2"
trap "sudo umount /mnt || :; sudo kpartx -dv \"\$img\"" EXIT
sudo kpartx -av "$img"
sudo mount -o loop /dev/loop0p$part /mnt
( cd /mnt && exec bash -il )
