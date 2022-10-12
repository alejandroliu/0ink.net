#!/bin/sh
#
# CURL based authentication
#
curl_k=""

while [ $# -gt 0 ]
do
  case "$1" in
    -k|--insecure) curl_k="-k" ;;
    *) break ;;
  esac
  shift
done

if [ $# -ne 1 ] ; then 
  echo "Usage: $0 [-k] url" 1>&2
  exit 1
fi

AUTH_URL="$1"

check_login() {
  local auth_url="$1" ; shift
  if [ $# -ge 2 ] ; then
    auth_url=$(echo "$auth_url" | sed \
    		-e "s|^https\?://|&${username}:${password}@|"
    		)
  fi
  res=$(curl $curl_k -s --write-out '%{http_code}' --output /dev/null "$auth_url" 2>&1)
  case "$res" in
    200) return 0
  esac
  return 1
}


if check_login "$AUTH_URL" ; then
  echo "Configured URL is not authenticating users: $AUTH_URL" 1>&2
  exit 1
fi
if check_login "$AUTH_URL" "$username" "$password" ; then
  echo "name = $username"
  exit 0  # OK
fi
exit 1  # FAILED


