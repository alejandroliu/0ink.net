#!/bin/sh
#
tmp=$(mktemp -p .) ; trap "rm -f $tmp" EXIT
for src in "$@"
do
  date="$(basename "$src" | cut -d- -f1-3)"
  echo -n "$date : $src : "
  awk '
    BEGIN {
      state = "starting"
      ft["date:"] = "'"$date"'"
    }
    $1 == "---" {
      if (state == "starting") {
	state = "header"
      } else if (state == "header") {
	state = "done"
	for (i in ft) {
	  print i " " ft[i]
	}
      }
      print
      next
    }
    {
      if (state == "done") {
	print
      } else if (state == "header") {
	if (!($1 in ft)) {
	  print
	}
      } else {
	print
      }
    }
  ' < "$src" >$tmp
  if ! cmp -s "$tmp" "$src" ; then
    echo "Updating"
    cat "$tmp" > "$src"
  else
    echo "No change"
  fi

done
