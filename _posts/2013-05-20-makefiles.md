---
ID: "109"
post_author: "2"
post_date: "2013-05-20 09:25:41"
post_date_gmt: "2013-05-20 09:25:41"
post_title: Makefiles
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: closed
post_password: ""
post_name: makefiles
to_ping: ""
pinged: ""
post_modified: "2013-05-20 09:25:41"
post_modified_gmt: "2013-05-20 09:25:41"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=109
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Makefiles
---

Some notes on GNU Make.  I always have to look-up these in
the manual.  Here now for my own convenience.


# GNU Make automatic variables:

From [http://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html](http://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html).

*   $@  
    The file name of the target of the rule.
*   $%  
    The target member name
*   $<  
    The name of the first prerequisite.
*   $?  
    The names of all the prerequisites that are newer.
*   $^  
    The names of all the prerequisites.

To include files in Makefile only if they exist:

```
ifneq ($(wildcard _incfile_),)
  include _incfile_
endif

```
