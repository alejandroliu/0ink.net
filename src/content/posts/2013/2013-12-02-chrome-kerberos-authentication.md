---
ID: "774"
post_author: "2"
post_date: "2013-12-02 11:01:53"
post_date_gmt: "2013-12-02 11:01:53"
post_title: Chrome Kerberos Authentication
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: chrome-kerberos-authentication
to_ping: ""
pinged: ""
post_modified: "2013-12-02 11:01:53"
post_modified_gmt: "2013-12-02 11:01:53"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=774
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Chrome Kerberos Authentication

date: 2013-12-02
tags: application, authentication, config
revised: 2021-12-22
---

To config chrome to use kerberos authentication you need to start the application the following parameter:

<ul>
<li>auth-server-whitelist - Allowed FQDN - Set the FQDN of the IdP Server. Example:

chrome --auth-server-whitelist="*aai-logon.domain-a.com"</p></li>
<li><p>auth-negotiate-delegate-whitelist - For which FQDN credential delegation will be allowed.</p></li>
</ul>

<p>References:

<ul>
<li><a href="http://www.chromium.org/developers/design-documents/http-authentication">HTTP Authentication</a></li>
<li><a href="http://kurt.seifried.org/2012/11/24/google-chrome-and-kerberos-on-linux/">Google Chrome &amp; Kerberos</a></li>
</ul>

