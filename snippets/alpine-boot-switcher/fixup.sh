#!/bin/sh
#
# Script to fix-up command line parameters
#
set -euf -o pipefail

xen_cmdline="dom0_mem=2048M"
die() {
  echo "$@" 1>&2
  exit $1
}

cfgfile=boot/grub/grub.cfg
[ ! -f "$cfgfile" ] && die 1 "$cfgfile: not found"

grep -q '/boot/xen\.gz' "$cfgfile" || die 2 "$cfgfile: not a xen config"

grep -q "$xen_cmdline" "$cfgfile" && die 3 "$cfgfile: fix-up already applied"

# Applying fix-up
inp=$(sed -e 's/^/:/' "$cfgfile")
out=$(echo "$inp" | sed -e 's!\(/boot/xen\.gz\).*!\1 '"$xen_cmdline"'!')
[ x"$inp" = x"$out" ] &&   die 4 "$cfgfile: no changes effected"

echo "$out" | sed -e 's/^://' > "$cfgfile"
die 0 "$cfgfile: fix-up applied"
