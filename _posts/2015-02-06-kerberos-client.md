---
ID: "886"
post_author: "2"
post_date: "2015-02-06 13:02:12"
post_date_gmt: "2015-02-06 13:02:12"
post_title: Kerberos Client
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: kerberos-client
to_ping: ""
pinged: ""
post_modified: "2015-02-06 13:02:12"
post_modified_gmt: "2015-02-06 13:02:12"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=886
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Kerberos Client
...
---

<ol>
<li>Make sure you have the pam&#095;krb5 rpm files installed. You can check this by running the <code>rpm -qa | grep pam</code> command and seeing whether the pam_krb5 rpm files are listed. If they aren't, you can typically download them in an update of the Linux or Unix operating system that you are running.</li>
<li>Add the line to the "/etc/pam.d/system-auth" part of the auth section of Kerberos. Add it after the "pam&#095;unix.so" line:

<pre><code>auth sufficient /lib/security/pam_krb5.so use_first_pass forwardable
</code></pre></li>
<li>Add the line to the "/etc/pam.d/system-auth" part of the password section of Kerberos. Add it after the "pam&#095;unix.so" line:

<pre><code>password sufficient /lib/security/pam_krb5.so use_authtok
</code></pre></li>
<li>Add the line to the "/etc/pam.d/system-auth" part of the session section of Kerberos. Add it after the "pam&#095;unix.so" line:

<pre><code>session optional /lib/security/pam_krb5.so
</code></pre></li>
</ol>
