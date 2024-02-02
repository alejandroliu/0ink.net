#!/bin/sh
#
# Make a Xen Image...
#
set -euf -o pipefail
if [ $# -eq 0 ] ; then
  echo "Usage: $0 _path_ _host_"
  exit 1
fi

fsroot="$1" ; shift
sysname="$1" ; shift

die() {
  echo "FATAL:""$@" 2>&1
  exit $1
}

[ -z "$fsroot" ] && die 5 "Missing FSroot"
[ -z "$sysname" ] && die 6 "Missing sysname"
[ ! -d "$fsroot" ] && die 7 "$fsroot: is not a directory"

svcdir="$fsroot/etc/runit/runsvdir/default"
echo "Customizing..."
echo "$sysname" > "$fsroot/etc/hostname"
cat > "$fsroot/etc/fstab" <<-_EOF_
	#
	# See fstab(5).
	#
	# <file system>	<dir>	<type>	<options>		<dump>	<pass>
	tmpfs		/tmp	tmpfs	defaults,nosuid,nodev	0 0
	/dev/xvda	/	xfs	rw,relatime,discard	0 1
	#/dev/xvdb	/home	xfs	rw,relatime,discard	0 2
	#/dev/xvdc	swap	swap 	defaults		0 0
	_EOF_
echo "root=/dev/xvda ro" > "$fsroot/boot/cmdline"

echo "Creating boot menus"
( cd "$fsroot/boot" && sh mkmenu.sh )

echo "Fixing services"
for svc in dhcpcd NetworkManager slim
do
  rm -f "$svcdir/$svc"
done
for notty in $(seq 1 9)
do
  rm -f "$svcdir/agetty-tty$notty"
done
con=hvc0
rm -f "$svcdir/agetty-$con"
ln -s /etc/sv/agetty-$con "$svcdir/agetty-$con"

echo "Saving capabilities"
find "$fsroot" -xdev -printf '%y %p\n' | sed -e "s!^\\(.\\) $fsroot/!\\1 !" | (while read t fpath
do
  [ x"$t" != x"f" ] && continue
  echo "$fpath"
done) | tr '\n' '\0' | ( cd "$fsroot" ; xargs -0 getcap ) > $fsroot/.caps


