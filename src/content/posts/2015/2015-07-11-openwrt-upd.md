---
title: Upload to OpenWRT
date: 2015-07-11
---

Base 64 decoding: `coreutils-base64`

```
#!/usr/local/bin/haserl --upload-limit=4096 --upload-dir=/tmp 
content-type: text/html

<html><body>
<form action="<% echo -n $SCRIPT_NAME %>" method=POST enctype="multipart/form-data" >
<input type=file name=uploadfile>
<input type=submit value=GO>
<br>
<% if test -n "$HASERL_uploadfile_path"; then %>
        <p>
        You uploaded a file named <b><% echo -n $FORM_uploadfile_name %></b>, and it was
        temporarily stored on the server as <i><% echo $HASERL_uploadfile_path %></i>.  The
        file was <% cat $HASERL_uploadfile_path | wc -c %> bytes long.</p>
        <% rm -f $HASERL_uploadfile_path %><p>Don't worry, the file has just been deleted
        from the web server.</p>
<% else %>
        You haven't uploaded a file yet.
<% fi %>
</form>
</body></html>
```

[haserl man page](http://haserl.sourceforge.net/manpage.html)


Uploader tool: [post](https://curl.haxx.se/docs/httpscripting.html#File_Upload_POST)

Disable/Relocate cgi-bin

