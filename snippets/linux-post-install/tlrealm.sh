#!/bin/sh
set -euf -o pipefail
root=sudo
mnt=/mnt

# this is very custom made...
if [ ! -d $mnt/etc/ssh ] ; then
  echo "No mounted filesystem"
  exit 1
fi

if [ $# -ne 1 ] ; then
  echo "Usage: $0 tlserver"
  exit 2
fi

target="$1"
syshost=$(cat $mnt/etc/hostname)
if (echo "$target" | grep '@') ; then
  tlserver=$(echo "$target" | cut -d@ -f2)
else
  tlserver="$target"
fi

echo Create host keys...
keytypes="dsa ecdsa ed25519 rsa"
tlrhome=/etc/tlr
for key in $keytypes
do
  $root rm -f $mnt/etc/ssh/ssh_host_${key}_key{,.pub}
  $root ssh-keygen -q -N '' -t $key -C "host:${key}@$syshost" -f "$mnt/etc/ssh/ssh_host_${key}_key"
done

echo Configure sshd...
sshd_config=/etc/ssh/sshd_config
extra_keys=/etc/ssh/userkeys/%u/authorized_keys
if ! grep -q "$extra_keys" "$mnt$sshd_config" ; then
  echo "Updating $sshd_config"
  ntxt="$(
	sed -e "s/^\(.*AuthorizedKeysFile\)/#TLR# \1/" -e 's/^/:/' $mnt$sshd_config
	echo ':'
	echo ":#TLR## Enabled $extra_keys for TLR deployed keys"
	echo ":AuthorizedKeysFile      .ssh/authorized_keys $extra_keys"
	)"
  echo "$ntxt" | sed -e 's/^://' | $root tee $mnt$sshd_config | md5sum || echo $?
fi
echo Registering $syshost on $tlserver
(for key in $keytypes
do
  cat $mnt/etc/ssh/ssh_host_${key}_key.pub
done) | ssh "$target" /usr/local/bin/hostmgr add "$syshost"
ssh "$target" $tlrhome/scripts/apply_policies
ssh "$target" tar -C $(dirname "$tlrhome") --exclude '*~'  -zcf - $(basename "$tlrhome") | \
  $root tar -C $(dirname "$mnt$tlrhome") -zxf -
$root ln -s $tlrhome/scripts/cron $mnt/etc/cron.hourly/tlr-upd
if [ -f $HOME/.ssh/known_hosts ] ; then
  ssh-keygen -R "$syshost" -f $HOME/.ssh/known_hosts || :
fi


