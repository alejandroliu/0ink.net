

## And then install non-free software:
##
## ```
#~ env XBPS_ARCH="$arch" xbps-install -y -S -R "$voidurl" -r $hmnt intel-ucode unrar
## ```

#begin-output
##
## ## System backups
##
## For [void linux][void] I prefer to re-install instead to do a full
## backup.  A few selected files are backed-up.  This is done with this
## [script]($repourl/rsvault.sh)
##
## To install, copy that script to `/usr/local/sbin` and make it
## executable.
##
## Create a cronjob in `/etc/cron.daily/rsvault` to enable.
##
## Configure server information in `/etc/rsync.cfg`
##
## ```
## rsync_host="<server>"
## rsync_passwd="<passwd>
## ```
##
## Make sure you set permissions accordingly:
##
## - `chmod 600 /etc/rsync.cfg`
##
## Create hardlinks to files that you would like to protect in
## `/etc/rsync.vault`.  For example:
##
## - `/etc/crypttab`
## - `/crypto_keyfile.bin`
## - `/etc/hosts` #: if using for ad blocking
##
## Alternatively, you can do a full backup with this
## [script]($repourl/os-backup.sh).
##
#end-output
if check_opt "rsync.secret" "$@" ; then
  rsync_host=$(check_opt "rsync.host" "$@") || rsync_host=vms3 # default rsync server
  wget -O$mnt/usr/local/sbin/rsvault $repourl/rsvault.sh
  printf '#!/bin/sh\n/usr/local/sbin/rsvault\n' > $mnt/etc/cron.daily/rsvault
  cat > $mnt/etc/rsync.cfg <<-_EOF_
	rsync_passwd=$(check_opt "rsync.secret" "$@")
	rsync_host=$rsync_host
	_EOF_
  chmod 600 $mnt/etc/rsync.cfg
  chmod 755 $mnt/usr/local/sbin/rsvault $mnt/etc/cron.daily/rsvault
  mkdir -p $mnt/etc/rsync.vault
fi
#begin-output
##
## ## Identd server
##
## I am using this [identd server]($identdurl/an_identd.py)to support
## a simple Single-Sign-On scheme.
##
## ```
mkdir -p $mnt/etc/sv/an_identd/log
wget -O$mnt/usr/local/sbin/an_identd $identdurl/an_identd.py
wget -O$mnt/etc/sv/an_identd/run $identdurl/etc-sv-an_identd/run
wget -O$mnt/etc/sv/an_identd/log/run $identdurl/etc-sv-an_identd/log/run
chmod 755 $mnt/usr/local/sbin/an_identd $mnt/etc/sv/an_identd/run $mnt/etc/sv/an_identd/log/run
ln -s /etc/sv/an_identd $svcdir
## ```
##


