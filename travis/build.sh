#!/bin/bash
#
# build.sh

set -euf -o pipefail

if [ "$1" != "$2" ]; then
  arch="-a $2"
fi
bootstrap="$1"
arch="$2"

if [ "$arch" = "x86_64-musl" ] ; then
  (
    cd /hostrepo/snippets/void-glibc-in-musl
    rm -f glibc
    gcc -s -o glibc glibc.c
    tar zcvf /hostrepo/glibc-$arch.tar.gz glibc
    rm -f glibc
  )
fi

ls -l

exit 0
