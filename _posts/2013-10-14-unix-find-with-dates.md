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

<code>-atime/-ctime/-mtime</code> the last time a files's <em>access time</em>, <em>file status</em> and <em>modification time</em>, measured in days or minutes. Time interval in options <code>-ctime</code>, <code>-mtime</code> and <code>-atime</code> is an integer with optional sign.

<ul>
<li><em>n</em>: If the integer <em>n</em> does not have sign this means exactly <em>n</em> days ago, <code>0</code> means today.</li>
<li><em>+n</em>: if it has <code>plus</code> sing, then it means <em>more then <strong>n</strong> days ago</em>, or older then <em>n</em>,</li>
<li><em>-n</em>: if it has the <code>minus</code> sign, then it means <em>less than <strong>n</strong> days ago (-n)</em>, or younger then <em>n</em>. It's evident that <code>-1</code> and <code>0</code> are the same and both mean <em>today</em>.</li>
</ul>

<h2>Examples:</h2>

<ul>
<li>Find everything in your home directory modified in the last 24 hours:

<code>$ find $HOME -mtime 0</code></p></li>
<li><p>Find everything in your home directory modified in the last 7 days:

<code>$ find $HOME -mtime -7</code></p></li>
<li><p>Find everything in your home directory that have <strong>NOT</strong> been modified in the last year:

<code>$ find $HOME -mtime +365</code></p></li>
<li><p>To find html files that have been modified in the last seven days, I can use -mtime with the argument -7 (include the hyphen):

<code>$ find . -mtime -7 -name "*.html" -print</code></p></li>
</ul>

<p>If you use the number <code>7</code> (without a hyphen), find will match only html files that were modified exactly seven days ago:

<pre><code> `$ find . -mtime 7 -name "*.html" -print`
</code></pre>

<ul>
<li>To find those html files that I haven't touched for at least 7 days, I use <code>+7</code>:

<p><code>$ find . -mtime +7 -name "*.html" -print</code></p></li>
</ul>

