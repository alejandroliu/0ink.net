Sample MD

# abcd

abc *ksdjf* _ekdjs_ acld

The quick brown fox jumped over the lazy dog.


<table border=1>
<%
  env | sort | while read LN
    do
      k=$(echo "$LN" | cut -d= -f1)
      v=$(echo "$LN" | cut -d= -f2-)
      [ -z "$k" ] && [ -z "$v" ] && continue
      echo '<tr>'
      echo "  <th align=\"left\">$k</th>"
      echo "  <td>$v</td>"
      echo '</tr>'
    done
%>
</table>

[.](<%= $SCRIPT_NAME${PATH_INFO:-}%>?edit=1)


