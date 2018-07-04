---
ID: "290"
post_author: "2"
post_date: "2013-05-23 11:43:56"
post_date_gmt: "2013-05-23 11:43:56"
post_title: PHP Tips
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: php-coding-style
to_ping: ""
pinged: ""
post_modified: "2013-05-23 11:43:56"
post_modified_gmt: "2013-05-23 11:43:56"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=290
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: PHP notes
---

Notes on doing different things within the PHP language.


# Object oriented introspection

*   property\_exists(obj,prop\_name)
*   method\_exists(obj,method\_name)
*   is\_a(obj,'clas\_name') or ($obj instanceof ClassName)

# Dynamic coding

*   Call a method: call\_user\_func(array($obj,'method',...args...)
*   You can simply $obj->prop = value to add properties.
*   or you can use \_\_set and \_\_get. See [http://php.net/manual/en/language.oop5.overloading.php](http://php.net/manual/en/language.oop5.overloading.php)

# varargs

*   [func\_get\_arg(num)](http://php.net/manual/en/function.func-get-arg.php)
*   [func\_get\_args()](http://www.php.net/manual/en/function.func-get-args.php)
*   [func\_get\_num_args()](http://www.php.net/manual/en/function.func-num-args.php)
