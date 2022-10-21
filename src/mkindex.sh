#!/bin/sh
#
# Generate a simple index
#
folder=$1
(
  cat <<-_EOF_
	<!DOCTYPE html>
	<html lang="en">
	  <head>
	    <meta charset="utf-8">
	    <title>$(basename "$folder")</title>
	    <meta name="viewport" content="width=device-width, initial-scale=1">
	  </head>
	  <body>
	    <h1>$(basename "$folder")</h1>
	    <ul>
	_EOF_

  ls -1 "$folder" | while read f
  do
    [ "$f" = "index.html" ] && continue
    echo "      <li><a href=\"$f\">$f</a></li>"
  done
  cat <<-_EOF_
	    </ul>
	  </body>
	</html>
	_EOF_
) > "$folder/index.html"
