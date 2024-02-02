#!/bin/sh

cuy_mode=htmlmixed
codemirror_url="https://cdn.jsdelivr.net/npm/codemirror@"
codemirror_ver="5.65.4"
codemirror_lnk() {
  echo "$codemirror_url$codemirror_ver/"
}

html_msg() {
  local status='' title='HTML msg' msg='none' lnks='' \
	location='' refresh='' toolbar="" xhead=''

  while [ $# -gt 0 ]
  do
    case "$1" in
    --status=*) status=${1#--status=} ;;
    --title=*) title=${1#--title=} ;;
    --msg=*) msg=${1#--msg=} ;;
    --location=*) location=${1#--location=} ;;
    --refresh=*) refresh=${1#--refresh=} ;;
    --toolbar=*)
      local v=${1#--toolbar=}
      if (echo "$v" | grep -q ,) ; then
	local k=$(echo "$v" | cut -d, -f1)
	v=$(echo "$v" | cut -d, -f2-)
      else
        local k="$v"
      fi
      [ -n "$toolbar" ] && toolbar="$toolbar : "
      toolbar="$toolbar<a href=\"$v\">$k</a>"
      ;;
    --home=*)
      [ -n "$toolbar" ] && toolbar="$toolbar : "
      toolbar="$toolbar<a href=\"${1#--home=}\">home</a>"
      ;;
    --no-toolbar) toolbar='' ;;
    --link=*)
      local v=${1#--link=}
      if (echo "$v" | grep -q ,) ; then
        local k=$(echo "$v" | cut -d, -f1)
	v=$(echo "$v" | cut-d, -f2-)
      else
        local k="$v"
      fi
      lnks="$lnks<li><a href=\"$v\">$k</a></li>"
      ;;
    --no-links) lnks="" ;;
    --head=*) xhead=${1#--head=} ;;
    *)
      msg="$*"
      break
    esac
    shift
  done
  echo "Content-type: text/html"
  [ -n "$status" ] && echo "Status: $status"
  [ -n "$location" ] && echo "Location: $location"
  [ -n "$refresh" ] && echo "Refresh: $refresh"
  echo ''
  cat <<-_EOF_
	<!DOCTYPE html>
	<html lang="en">
	  <head>
	    <meta charset="utf-8">
	    <title>$title</title>
	    <meta name="viewport" content="width=device-width, initial-scale=1">
	_EOF_
  [ -n "$xhead" ] && echo "$xhead"
  [ -n "$refresh" ] && echo "<meta http-equiv=\"refresh\" content=\"$refresh\" />"
  cat <<-_EOF_
	  </head>
	  <body>
	    <h1>$title</h1>
	_EOF_
  [ -n "$toolbar" ] && echo "<hr>$toolbar<hr>"

  echo "$msg"

  if [ -n "$lnks" ] ; then
    echo "<ul>$lnks</ul>"
  fi
  echo "</body>"
  echo "</html>"
}

html_enc() {
  local rules='s/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'
  if [ $# -eq 0 ] ; then
    sed "$rules"
  else
    echo "$@" | sed "$rules"
  fi
}

url_decode() {
  if [ $# -eq 0 ] ; then
    printf '%b\n' "$(sed 's/+/ /g; s/%\([0-9a-fA-F][0-9a-fA-F]\)/\\x\1/g;')"
  else
    echo "$*" | url_decode
  fi
}

post_data() {
  #~ local in_raw

  [ x"$REQUEST_METHOD" != x"POST" ] && return
  [ -z "$CONTENT_LENGTH" ] && return
  if [ "$CONTENT_LENGTH" -gt 0 ]; then
    #~ read -r -n $CONTENT_LENGTH in_raw
    #~ echo "$in_raw"
    cat
    export CONTENT_LENGTH=0
  fi
}

query_string_raw() {
  local var="$1" ; shift
  local qstr=$(echo "$*" | tr ';' '&') keyw
  if [ -n "$qstr" ] ; then
    export IFS="&"
    for keyw in ${qstr}
    do
      if ( echo "$keyw" | grep -q '=') ; then
	local \
	  key="$(echo "$keyw" | cut -d= -f1)" \
	  val="$(echo "$keyw" | cut -d= -f2-)"
	if [ x"$key" = x"$var" ] ; then
	  echo "$val"
	fi
      fi
    done
  fi
}

query_string() {
  query_string_raw "$@" | url_decode
}

cuy_header() {
  local mode=$cuy_mode
  while [ $# -gt 0 ]
  do
    case "$1" in
      --html) mode=html ;;
      --md|--markdown) mode=markdown ;;
      --mode=*) mode=${1#--mode} ;;
      *) break
    esac
    shift
  done
  local cm_libs=""

  case "$mode" in
  yaml)
    cm_libs="mode/yaml/yaml.min.js"
    ;;
  markdown)
    cm_libs="addon/edit/continuelist.min.js mode/xml/xml.min.js mode/javascript/javasctipt/min.js mode/markdown/markdown.min.js mode/php/php.min.js"
    ;;
  *)  # HTMLmixed is the default
    cm_libs="mode/xml/xml.min.js mode/javascript/javascript.min.js mode/css/css.min.js mode/htmlmixed/htmlmixed.min.js"
    ;;
  esac

  cat <<-_EOF_
	<script src="$(codemirror_lnk)lib/codemirror.min.js"></script>
	<link href="$(codemirror_lnk)lib/codemirror.min.css" rel="stylesheet">
	<style>
	.CodeMirror {
	  border: 1px solid #eee;
	  height: auto;
	}
	</style>
	_EOF_

  for cm_lib in $cm_libs
  do
    echo "<script src=\"$(codemirror_lnk)$cm_lib\"></script>"
  done
}

cuy_editform() {
  local method=post form=edform field=payload action=""

  while [ $# -gt 0 ]
  do
    case "$1" in
      --method=*) method=${1#--method=} ;;
      --form=*) form=${1#--form=} ;;
      --field=*) field=${1#--field=} ;;
      --no-action) action='' ;;
      --action=*) action=${1#--action=} ;;
      *) break
    esac
    shift
  done

  cat <<-_EOF_
	<form method="$method" id="$form" $([ -n "$action" ] && echo action=\""$action"\" )>
	  <input type="hidden" id="$field" name="$field">
	  $([ -n "$*" ] &&  echo "$*")
	</form>
	_EOF_
}

cuy_editarea() {
  local id='editarea' js=true save_cb='' cm_mode=$cuy_mode line_numbers=true
  while [ $# -gt 0 ]
  do
    case "$1" in
    --id=*) id=${1#--id=} ;;
    --no-js) js=false ;;
    --js) js=true ;;
    --no-save-cb) save_cb='' ;;
    --save-cb=*) save_cb=${1#--save-cb=} ;;
    --cm-cmode=*) cm_mode=${1#--cm-cmode=} ;;
    --html) cm_mode=htmlmixed ;;
    --md|--markdown) cm_mode=markdown ;;
    --line-numbers) line_numbers=true ;;
    --no-line-numbers) line_numbers=false ;;
    *) break ;;
    esac
    shift
  done
  echo "<textarea id=\"$id\">"
  if [ $# -gt 0 ] ; then
    if [ -r "$1" ] ; then
      cat "$1" | html_enc
    fi
  fi
  echo "</textarea>"

  if $js ; then
    echo "<script>"
    echo "$id = CodeMirror.fromTextArea(document.getElementById(\"$id\"), {"
    if [ -n "$save_cb" ] ; then
      echo "    extraKeys: { \"Ctrl-S\": function(instance) { $save_cb } },"
    fi
    echo "    lineNumbers: $line_numbers,"
    echo "    mode: \"$cm_mode\""
    echo "});"
    echo "</script>"
  fi
}

cuy_savecb() {
  local id='editarea' save_cb='cm_save' form=edform field=payload
  while [ $# -gt 0 ]
  do
    case "$1" in
    --id=*) id=${1#--id=} ;;
    --save-cb=*) save_cb=${1#--save-cb=} ;;
    --form=*) form=${1#--form=} ;;
    --field=*) field=${1#--field=} ;;
    *) break ;;
    esac
    shift
  done

  echo '<script>'
  echo "
	    function $save_cb() {
	      var txt = $id.getDoc().getValue();
	      document.getElementById(\"$field\").value = txt;
	      document.getElementById(\"$form\").submit();
	    }
	"
  echo '</script>'
}

cuy_render() {
  local mode=html pp=true header=true haserl=false
  while [ $# -gt 0 ]
  do
    case "$1" in
    --html) mode=html ;;
    --md|--markdown) mode=markdown ;;
    --pp) pp=true ; haserl=false ;;
    --haserl) haserl=true ; pp=false ;;
    --no-pp) pp=false ; haserl=false ;;
    *) break
    esac
    shift
  done

  if $pp ; then
    content="$(
      eof='__EOF_CUT_HERE_EOF__'
      echo "cat <<$eof"
      cat "$1"
      echo ''
      echo "$eof"
    )"
    content="$(eval "$content")"
  elif $haserl ; then
    content="$(REQUEST_METHOD=GET CONTENT_LENGTH= haserl "$1")"
  else
    content="$(cat "$1")"
  fi
  case "$mode" in
  html) : ;; # do nothing
  markdown)
    content="$(echo "$content" | markdown)" ;;
  esac

  echo "$content"
}

cuy_editapp() {
  local \
	doc="" \
	mode=htmlmixed \
	home="${SCRIPT_NAME}${PATH_INFO:-}" \
	id='editarea' \
	save_cb='cm_save' \
	form=edform \
	field=payload

  while [ $# -gt 0 ]
  do
    case "$1" in
    --doc=*) doc=${1#--doc=} ;;
    --mode=*) mode=${1#--mode=} ;;
    --home=*) home=${1#--home=} ;;
    --id=*) id=${1#--id=} ;;
    --save-cb=*) save_cb=${1#--save-cb=} ;;
    --form=*) form=${1#--form=} ;;
    --field=*) field=${1#--field=} ;;
    *) break ;;
    esac
    shift
  done

  # Edit mode
  if [ x"$REQUEST_METHOD" = x"POST" ] ; then
    if [ -n "${HASERLVER:-}" ] ; then
      eval "payload=\"\${FORM_${field}}\""
      payload="$(echo "$payload" | tr -d '\r')"
    else
      post_data="$(post_data)"
      payload="$(query_string $field "$post_data" | tr -d '\r')"
    fi

    if [ -z "$payload" ] ; then
      html_msg --title="Error" --home="$SCRIPT_NAME" "No payload"
    else
      if [ -w "$doc" ] ; then
	html_msg \
	      --title="$doc: saving..." \
	      --refresh="1; $home" \
	      --home="$home" \
	      "New document contents" \
	      "<pre>" \
	      "$(echo "$payload" | tee "$doc" | html_enc)" \
	      "</pre>"
      else
	html_msg \
	      --status="403 Permission denied" \
	      --title="Error" \
	      --home="$home" \
	      "Permission denied"
      fi
    fi
  else
    #~ html_msg "Write post"
    html_msg \
	--title="$doc: editing" \
	--home="$home" \
	--toolbar="save,javascript:${save_cb}();" \
	--head="$(cuy_header --mode=$mode)" \
	"$(
	    cuy_editarea --save-cb="${save_cb}();" "$doc"
	    cuy_editform --form=$form --field=$field
	    echo "<hr/>"
	    cuy_savecb --id=$id --form=$form --field=$field
	)"
  fi
}

#~ query_string tool "${QUERY_STRING:-}"

