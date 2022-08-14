#!/bin/bash
set -euf -o pipefail
. ./cuylib.sh

doc=sample-haserl.md
if [ -n "$(query_string edit "${QUERY_STRING:-}")" ] ; then
  cuy_editapp --doc=$doc --mode=markdown
else
  html_msg \
      --title="$doc: demo" \
      "$(cuy_render --haserl --md "$doc")"
fi
exit

