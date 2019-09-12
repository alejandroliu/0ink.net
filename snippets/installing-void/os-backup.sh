#!/bin/sh

set -euf -o pipefail

if [ -f /etc/rsync.cfg ] ; then
  . /etc/rsync.cfg
fi

rsync_v="-h --stats --progress"
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

# -a :-rlptgoD --no-perms --no-group --no-owner --no-D (devices/specials)
# -H
# -A
# -X
# -v|-q
# -z

# getfacl | for permissions and acl's
# getcaps
# tar | for special files

if [ $# -eq 0 ] ; then
  src=/
else
  src="$(echo "$1" | sed -e 's!/*$!/!')"
fi
if [ ! -d "$src" ] ; then
  echo "$src: not a directory" 1>&2
  exit 1
fi

exec 3>&1
find "$src" \
	-xdev \
	-printf '%y %p\n' | (
  (
    exec 4>&1 # 4: goes to getfacl
    (
      exec 5>&1 # 5: goes to stat listings...
      (
	exec 6>&1 # 6: goes to getcaps
	(
	  exec 7>&1 # 7: goes to tar
	  exec 1>&3 ; exec 3>&- # Restore stdout...
	  while read t fp
	  do
	    if [ "$t" = "f" -o "$t" = "d" ] ; then
	      if [ x"$fp" != x"/" ] ; then
		echo "$fp" 1>&4
	      fi
	    fi
	    if [ "$t" = "l" ] ; then
	      echo "$fp" 1>&5
	    fi
	    if [ $t = "f" ] ; then
	      echo "$fp" 1>&6
	    fi
	    if [ $t != "f" -a $t != "l" -a $t != "d" ] ; then
	      echo "$fp" 1>&7
	    fi
	  done
	) | (
	  exec 1>&3
	  tr '\n' '\0' | tar -zcf "$src.specials.tar.gz" --no-recursion --null --files-from=-
	)
      ) | (
	exec 1>&3
	tr '\n' '\0' | xargs -0 getcap | tee "$src.caps" | md5sum
      )
    ) | (
      # Handle symlink ownership
      exec 1>&3
      tr '\n' '\0' | xargs -0 stat -c '%u:%g %n' | gzip -v | tee "$src.symlnks.gz" | md5sum
    )
  ) | (
    # Handle facl numerics...
    exec 1>&3
    cd "$src" || exit 1
    sed -e 's!^'"$src"'!!' \
	| tr '\n' '\0' \
	| xargs -0 getfacl -p -n \
	| gzip -v | tee "$src.facl.gz" | md5sum
  )
)


for d in "root/:/" "boot/:/boot/"
do
  ext=$(echo "$d" |cut -d: -f1)
  d=$(echo "$d" | cut -d: -f2)
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
	"$src$d" \
	"${rsync_user}@${rsync_host}::${rsync_module}/${ext}"
done

