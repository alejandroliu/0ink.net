---
ID: "614"
post_author: "2"
post_date: "2013-07-02 07:43:24"
post_date_gmt: "2013-07-02 07:43:24"
post_title: 'Mini-Howto: Setup proxy on Ubuntu'
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: mini-howto-setup-proxy-on-ubuntu
to_ping: ""
pinged: ""
post_modified: "2016-11-14 13:09:24"
post_modified_gmt: "2016-11-14 13:09:24"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=614
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: 'Mini-Howto: Setup proxy on Ubuntu'
...
---

<img src="https://0ink.net/wp-content/uploads/2013/07/logo-ubuntu_su-orange-hex.jpg" alt="logo-ubuntu_su-orange-hex" width="284" height="64" class="alignnone size-full wp-image-995" />

This one is short and sweet:

<ol>
<li>Install Squid with the following command at the Linux command prompt:<br />
<code>sudo apt-get install squid</code></li>
<li>Edit the Squid config file in <code>/etc/squid</code> adding these lines:<br />
<code>http_access allow local_net</code><br />
<code>acl local_net src 10.10.0.0/255.255.0.0</code>  </li>
<li>Save the file, exit the editor and restart Squid. You are now ready to configure your browser to use the proxy server.</li>
<li>Click "Tools," "Options," "Advanced," "Network" and "Settings" in Firefox, which is the normal Ubuntu Linux browser. Select "Manual Proxy Configuration," enter the IP address of your proxy server, enter port 3128 in the Port field and then click "OK."</li>
</ol>

References:

<ul>
<li><a href="http://science.opposingviews.com/set-up-secure-proxy-server-ubuntu-linux-23184.html">http://science.opposingviews.com/set-up-secure-proxy-server-ubuntu-linux-23184.html</a> by Alan Hughes</li>
</ul>

