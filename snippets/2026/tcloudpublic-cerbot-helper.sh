#!/bin/sh
set -euf ; ( set -o pipefail 2>/dev/null ) && set -o pipefail || :
exec 3>&1  >&2 # All output to certbot goes to 3

DNS_API_ENDPOINT="https://dns.${OS_REGION_NAME:=eu-de}.otc.t-systems.com"
echo Using TTL=${RECORD_TTL:=60} WAIT=${PROPAGATION_SLEEP:=60}
echo Retries=${API_RETRIES:=5} wait=${API_WAIT:=10}

check_vars() {
  local i j k=""
  for i in "$@"
  do
    eval j=\"\${$i:-}\"
    [ -z "$j" ] && k="$k $i"
  done
  [ -z "$k" ] && return 0
  echo "Missing:$k" 1>&2
  exit 1
}

die() {
  echo "$@" 1>&2
  exit 2
}

api() {
  local retries=$API_RETRIES
  if [ -n "${OS_ACCESS_KEY:-}" ] ; then
    autocfg=false
  else
    autocfg=true
  fi

  while [ $retries -gt 0 ]
  do
    if [ -z "${OS_ACCESS_KEY:-}" ] ; then
      # OK, no AK, try to use metadata agency
      local creds=$(curl -s http://169.254.169.254/openstack/latest/securitykey)
      [ -z "$creds" ] && die "Missing auth configuration"
      export \
	OS_ACCESS_KEY=$(echo "$creds" | jq -r .credential.access) \
	OS_ACCESS_SECRET=$(echo "$creds" | jq -r .credential.secret) \
	OS_ACCESS_TOKEN=$(echo "$creds" | jq -r .credential.securitytoken)
    fi
    local resp=$(python3 curler.py "$@")
    if [ x"$(echo  "$resp" | jq 'length == 2 and has("code") and has("message")')" = x"true" ] ; then
      echo "$1 $2: $(echo "$resp" | jq -r .message)" 1>&2
      $autocfg || return 1
    else
      echo "$resp"
      return 0
    fi
    OS_ACCESS_KEY="" # Re-authenticate
    retries=$(expr $retries - 1) || return 0
    [ $retries -gt 0 ] && sleep $API_WAIT
  done
  return 2
}

find_zone_id() {
  local zone_name=$(echo "$1" | cut -d. -f 2-)
  local dnszones=$(api GET "$DNS_API_ENDPOINT/v2/zones?$zone_name.")

  local NS_ZONE=$(echo "$dnszones" | jq -e '.zones[] | select(.name == "'"$zone_name"'.")')
  local zid=$(echo "$NS_ZONE" | jq -r .id) || die "$zone_name: zone not found"

  echo "$zid"
}

auth_hook() {
  local zone_id=$(find_zone_id "$CERTBOT_DOMAIN")
  [ -z "$zone_id" ] && exit 1

  # Build the _acme-challenge record name.  certbot may pass "example.com" or
  # a subdomain; always prepend _acme-challenge.
  local record_name="_acme-challenge.${CERTBOT_DOMAIN}"   # trailing dot = FQDN
  local subzone=$(find_zone_id "$record_name")
  if [ -z "$subzone" ] ; then
    # Create the zone to host the challenge...
    local resp=$(api POST \
	"$DNS_API_ENDPOINT/v2/zones" \
	'{
	    "name": "'"$CERTBOT_DOMAIN"'",
	    "zone_type": "public",
	    "ttl": '"$RECORD_TTL"'
	  }')
    [ -z "$resp" ] && die "Error creating holding zone"
    subzone=$(echo "$resp" | jq -r .id)
    echo "subzone $subzone" 1>&3
  fi

  echo "zone_id: $zone_id"
  echo "subzone_id: $subzone"

  local resp=$(api POST \
      "$DNS_API_ENDPOINT/v2/zones/$subzone/recordsets" \
      '{
	  "name": "'"$record_name."'",
	  "type": "TXT",
	  "ttl": "'"$RECORD_TTL"'",
	  "records": [ "\"'"$CERTBOT_VALIDATION"'\"" ]
	}')
  [ -z "$resp" ] && die "Error creating challenge string"
  echo "$resp"
  recset=$(echo "$resp" | jq -r .id)
  echo rrs "$subzone" "$recset" 1>&3

  sleep $PROPAGATION_SLEEP
}

cleanup_hook() {
  echo "${CERTBOT_AUTH_OUTPUT}" | (while read mode ids
  do
    case "$mode" in
    rrs)
      set - $ids
      api DELETE "$DNS_API_ENDPOINT/v2/zones/$1/recordsets/$2"
      ;;
    subzone)
      api DELETE  "$DNS_API_ENDPOINT/v2/zones/$ids"
      ;;
    esac
  done)
}

check_vars CERTBOT_DOMAIN CERTBOT_VALIDATION

: \
  ${CERTBOT_REMAINING_CHALLENGES:=0} \
  ${CERTBOT_ALL_DOMAINS:=} \
  ${OS_REGION_NAME:=eu-de}

case "$1" in
auth)
  auth_hook
  ;;
clean)
  cleanup_hook
  ;;
*)
  die "Unknown op"
  ;;
esac
