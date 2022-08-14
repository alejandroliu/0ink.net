#!/usr/bin/haserl
<% set -euf
. ./cuylib.sh

doc=sample-pp.md
if [ x"$REQUEST_METHOD" = x"POST" ] || [ -n "${GET_edit:-}" ] ; then
  cuy_editapp --doc=$doc --mode=markdown
else
  html_msg \
      --title="$doc: demo" \
      "$(cuy_render --md "$doc")"
  #~ html_msg --title=mode "Render mode $QUERY_STRING <pre>$msg</pre>"
fi
%>
