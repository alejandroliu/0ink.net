---
ID: "1031"
post_author: "2"
post_date: "2017-01-25 12:39:05"
post_date_gmt: "0000-00-00 00:00:00"
post_title: Portable Console
post_excerpt: ""
post_status: draft
comment_status: open
ping_status: open
post_password: ""
post_name: ""
to_ping: ""
pinged: ""
post_modified: "2017-01-25 12:39:05"
post_modified_gmt: "2017-01-25 12:39:05"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1031
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Portable Console
---

portable console


Set scrolling region:

~~~bash
printf "\033[1;24r"
~~~

Reset scrolling region:


~~~bash
printf "\033[r"
~~~

However, it is easier/better to do:

~~~bash
stty rows 24 cols 80
~~~

