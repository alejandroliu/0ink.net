#!/bin/sh
#
# Install SSH keys
#
set -euf -o pipefail
die() {
  echo "$@" 1>&2
  exit "$1"

}

if [ $# -eq 0 ] ; then
  cat 1>&2 <<-_EOF_
	Usage:
	  $0 server
	_EOF_
  exit 1
fi
if [ -n "${SSH_AUTH_KEYS:-}" ] ; then
  authkeys="$SSH_AUTH_KEYS"
else
  authkeys='$HOME/.ssh/authorized_keys'
fi

server="$1" ; shift

#
# Sanity checks...
#
ping -q -c 1 "$server" || die 22 "$server: not found"
[ -r /net/$server/netcfg/registry.yaml ] || die 31 "$server: no netcfg/registry.yaml found"
admin_user=$(yq -r '.admin // "admin"' < /net/$server/netcfg/registry.yaml)
ssh -o BatchMode=yes -l "$admin_user" "$server" true </dev/null || die 33 "ssh BATCH access denied"

[ -r /net/$server/netcfg/admin.yaml ] || die 31 "$server: no netcfg/admin.yaml found"
sshpubkey=$(yq -re .qsnap.sshkeys.public < /net/$server/netcfg/admin.yaml) || die 35 "ssh public key not found"
sshcmd=$(yq -r .qsnap.sshcmd < /net/$server/netcfg/admin.yaml) || die 36 "sshcmd not configured"

main() {
  if [ -f "$authkeys" ] ; then
    text="$(sed -e 's/^/:/' "$authkeys")"
  else
    text=""
  fi

  # Remove duplicate keys...
  keyid=$(echo "$sshpubkey" | awk '{print $NF}')
  text="$(echo "$text" | awk '$NF != "'"$keyid"'"')"

  (
    echo "$text" | sed -e 's/^://'
    echo -n "command=\"/share$sshcmd\""
    echo -n ',no-agent-forwarding,no-port-forwarding,no-pty,no-x11-forwarding'
    echo -n ' '
    echo "$sshpubkey"
  ) > "$authkeys"

  mkdir -p "/share$(dirname $sshcmd)"
}

EOF="_XYL_KJF_CKLD_"
ssh -o BatchMode=yes -T -l "$admin_user" "$server" <<_EOF_
set -euf -o pipefail
authkeys=$authkeys
$(declare -f main)
$(declare -p sshpubkey)
$(declare -p sshcmd)
main
$(
  if [ -f qsnap.remote ] ; then
    echo "sed -e 's/^://' >\"/share\$sshcmd\" <<'$EOF'"
    echo "$(sed -e 's/^/:/' qsnap.remote)"
    echo "$EOF"
    echo "chmod 755 \"/share\$sshcmd\""
  fi
)
_EOF_
