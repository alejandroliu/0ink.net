---
ID: "690"
post_author: "2"
post_date: "2013-10-14 07:59:48"
post_date_gmt: "2013-10-14 07:59:48"
post_title: UNIX find with dates
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: unix-find-with-dates
to_ping: ""
pinged: ""
post_modified: "2013-10-14 07:59:48"
post_modified_gmt: "2013-10-14 07:59:48"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=690
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: UNIX find with dates
---

`-atime/-ctime/-mtime` the last time a files's _access time_, _file status_ and _modification time_, measured in days or minutes. Time interval in options `-ctime`, `-mtime` and `-atime` is an integer with optional sign.

*   _n_: If the integer _n_ does not have sign this means exactly _n_ days ago, `0` means today.
*   _+n_: if it has `plus` sing, then it means _more then **n** days ago_, or older then _n_,
*   _-n_: if it has the `minus` sign, then it means _less than **n** days ago (-n)_, or younger then _n_. It's evident that `-1` and `0` are the same and both mean _today_.

## Examples:

*   Find everything in your home directory modified in the last 24 hours: `$ find $HOME -mtime 0`
    
*   Find everything in your home directory modified in the last 7 days: `$ find $HOME -mtime -7`
    
*   Find everything in your home directory that have **NOT** been modified in the last year: `$ find $HOME -mtime +365`
    
*   To find html files that have been modified in the last seven days, I can use -mtime with the argument -7 (include the hyphen): `$ find . -mtime -7 -name "*.html" -print`
    

If you use the number `7` (without a hyphen), find will match only html files that were modified exactly seven days ago:

```
 `$ find . -mtime 7 -name "*.html" -print`

```

*   To find those html files that I haven't touched for at least 7 days, I use `+7`:
    
    `$ find . -mtime +7 -name "*.html" -print`
