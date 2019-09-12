#!/bin/sh
#
# This script is to backup a small set of files in
# `/etc/rsync.vault` to an `rsync` server.
#
# Configuration:
#
# Create a file `/etc/rsync.cfg`.  Make sure the modes are 0600.
#
# ```
# rysnc_passwd=secret_password
# rsync_host=rsync_server_host_name
# ```
#
set -euf -o pipefail
rsync_vault=/etc/rsync.vault
#~ rsync_v=''
rsync_v="-h --stats"


if [ -f /etc/rsync.cfg ] ; then
  . /etc/rsync.cfg
fi

#~ rsync_v="-h --stats --progress"
rsync_module=$(hostname)
rsync_user=$rsync_module

do_fail=false
for a in rsync_passwd rsync_host
do
  eval k=\${$a:-}
  if [ -z "$k" ] ; then
    echo "Must define $a in /etc/rsync.cfg"
    do_fail=true
  fi
done
$do_fail && exit 1 || :

(
  exec 2>&1
  env RSYNC_PASSWORD="$rsync_passwd" rsync \
	$rsync_v \
	--recursive \
	--links \
	--times \
	--hard-links \
	--xattrs \
	--sparse \
	--delete \
	--one-file-system \
	--exclude="/var/log" --exclude="*.bak" --exclude="*~" \
	--filter='dir-merge /.rsync-filter' --include=.git \
	--compress \
	$rsync_vault/ \
	"${rsync_user}@${rsync_host}::${rsync_module}/vault/"
) | logger -t $(basename "$0")
