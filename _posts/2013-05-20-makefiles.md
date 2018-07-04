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

<h1>GNU Make automatic variables:</h1>

From <a href="http://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html">http://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html</a>.

<ul>
<li>$@<br />
The file name of the target of the rule.</li>
<li>$%<br />
The target member name</li>
<li>$&lt;<br />
The name of the first prerequisite.</li>
<li>$?<br />
The names of all the prerequisites that are newer.</li>
<li>$^<br />
The names of all the prerequisites.</li>
</ul>

To include files in Makefile only if they exist:

<pre><code>ifneq ($(wildcard _incfile_),)
  include _incfile_
endif
</code></pre>

