#!/bin/sh
set -euf ; ( set -o pipefail >/dev/null 2>&1 ) && set -o pipefail || :

check_image() {
  local rest="${1%%:*}" tag="${1##*:}"
  local regex="$2"
  local first_segment="${rest%%/*}"
  case "$first_segment" in
  *.*|*:*)
    registry="${first_segment}"
    image="${rest#*/}"
    ;;
  *)
    registry=""
    image="$rest"
    ;;
  esac
  case "$image" in
  */*)
    fqimg="$image"
    ;;
  *)
    fqimg="library/$image"
    ;;
  esac

  if [ -z "$registry" ] ; then
    # hub.docker.com shenanigans....
    local token=$(curl -s \
      "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${fqimg}:pull" \
      | jq -r '.token')
    local tags=$(curl -s \
	-H "Authorization: Bearer $token" \
	"https://registry-1.docker.io/v2/${fqimg}/tags/list" \
	| jq -r '.tags[]' )
  else
    local token=$(curl -s \
      "https://$registry/token?service=$registry&scope=repository:${fqimg}:pull" \
      | jq -r '.token')
    local tags=$(curl -s \
	      -H "Authorization: Bearer $token" \
	      "https://$registry/v2/${fqimg}/tags/list" \
	      | jq -r '.tags[]' )
  fi

  tags=$(printf "%s\n" $tags \
	  | (
	    if [ -n "$regex" ] ; then
	      grep -P "$regex" || :
	    else
	      cat
	    fi
	  ) | sort -V)
  local newer=$(echo "$tags" | awk -v current="$tag" '
    $0 == current { seen = 1 ; next }
    seen
  ')
  if [ -z "$newer" ] ; then
    echo "$tags"
  else
    echo "$newer"
  fi
}

#~ for i in "$@"
#~ do
  #~ check_image $i
#~ done

check_image nginx:1.25.3 '^\d+\.\d+\.\d+$'
#~ check_image library/nginx:1.25.3
check_image ghcr.io/tortugalabs/mylldap:v0.6.2-2026.02 ''
