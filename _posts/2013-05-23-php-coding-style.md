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
title: PHP Tips
...
---

<h1>Object oriented introspection</h1>

<ul>
<li>property_exists(obj,prop_name) </li>
<li>method_exists(obj,method_name) </li>
<li>is_a(obj,'clas_name') or ($obj instanceof ClassName) </li>
</ul>

<h1>Dynamic coding</h1>

<ul>
<li>Call a method: call_user_func(array($obj,'method',...args...) </li>
<li>You can simply $obj-&gt;prop = value to add properties.</li>
<li>or you can use __set and __get. See <a href="http://php.net/manual/en/language.oop5.overloading.php">http://php.net/manual/en/language.oop5.overloading.php</a></li>
</ul>

<h1>varargs</h1>

<ul>
<li><a href="http://php.net/manual/en/function.func-get-arg.php">func_get_arg(num)</a></li>
<li><a href="http://www.php.net/manual/en/function.func-get-args.php">func_get_args()</a></li>
<li><a href="http://www.php.net/manual/en/function.func-num-args.php">func_get_num_args()</a></li>
</ul>

