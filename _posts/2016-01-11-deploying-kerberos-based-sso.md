---
ID: "954"
post_author: "2"
post_date: "2016-01-11 15:14:13"
post_date_gmt: "2016-01-11 15:14:13"
post_title: Deploying Kerberos based SSO
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: deploying-kerberos-based-sso
to_ping: ""
pinged: ""
post_modified: "2016-01-11 15:14:13"
post_modified_gmt: "2016-01-11 15:14:13"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=950
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Deploying Kerberos based SSO
...
---

<h2>Pre-requisites</h2>

<ul>
<li>Kerberos Domain Controller (KDC)</li>
<li>User accounts in the KDC</li>
<li>KDC based logins</li>
</ul>

To make sure that this is working, login to your workstation using
your kerberos password and use the command:

<pre><code>klist
</code></pre>

This should show your principals assigned to you.

<pre><code>Ticket cache: FILE:/tmp/krb5cc_XXXX_ErVb5X
Default principal: zzzz@LOCALNET

Valid starting       Expires              Service principal
01/11/2016 15:51:35  01/12/2016 15:51:34  krbtgt/LOCALNET@LOCALNET
</code></pre>

<h2>Configuring Apache</h2>

<ol>
<li>Install any necessary modules on the server:

<ul>
<li><code>yum install mod_auth_kerb</code></li>
</ul></li>
<li>Create a service principal for the web server (this needs to be
done on the KDC.

<ul>
<li><code>kadmin.local -q "addprinc -randkey HTTP/www.example.com</code></li>
</ul></li>
<li>Export the encpryption keys to a keytab:

<ul>
<li><code>kadmin.local -q "ktadd -k /tmp/http.keytab HTTP/www.example.com</code></li>
</ul></li>
<li>Copy <code>/tmp/http.keytab</code> to the webserver at
<code>/etc/httpd/http.keytab</code>.</li>
<li>Set ownership and permissions:

<ul>
<li><code>chmod 600 /etc/httpd/http.keytab</code></li>
<li><code>chown apache /etc/httpd/http.keytab</code></li>
</ul></li>
<li>Enable authentication, configure this:

<ul>
<li><code>AuthType Kerberos</code></li>
<li><code>AuthName "Acme Corporation"</code></li>
<li><code>KrbMethodNegotiate on</code></li>
<li><code>KrbMethodK5Passwd off</code></li>
<li><code>Krb5Keytab /etc/httpd/http.keytab</code></li>
<li><code>require valid-user</code></li>
</ul></li>
<li>Re-start apache</li>
</ol>

<h2>Configure FireFox</h2>

<ol>
<li>Navigate to <code>about:config</code></li>
<li>Search for: <code>negotiate-auth</code></li>
<li>Double click on <code>network.negotiate-auth.trusted-uris</code>.</li>
<li>Enter hostname's, URL prefixes, etc, separated by commas.
Examples:

<ul>
<li>www.example.com</li>
<li>http://www.example.com/</li>
<li>.example.com</li>
</ul></li>
</ol>

It is possible to configure this setting for all users by creating a global config file:

<ol>
<li>Find configuration directory:

<ul>
<li><code>rpm -q firefox -l | grep preferences</code></li>
</ul></li>
<li>Create a javascript file in that directory.  (by convention, <code>autoconfig.js</code>; other
file names will work, but for best results it should be early in the alphabet.)</li>
<li>Add the following line:

<ul>
<li><code>pref("network.negotiate-auth.trusted-uris",".example.com");</code></li>
</ul></li>
</ol>

<h2>Configure OpenSSH server</h2>

<ol>
<li>Create a service principal for the host (this needs to be
done on the KDC.

<ul>
<li><code>kadmin.local -q "addprinc -randkey host/shell.example.com</code></li>
</ul></li>
<li>Export the encpryption keys to a keytab:

<ul>
<li><code>kadmin.local -q "ktadd -k /tmp/krb5.keytab host/shell.example.com</code></li>
</ul></li>
<li>Copy <code>/tmp/krb5.keytab</code> to the host at:
<code>/etc/krb5.keytab</code>.</li>
<li>Set ownership and permissions:

<ul>
<li><code>chmod 600 /etc/krb5.keytab</code></li>
<li><code>chown root /etc/krb5.keytab</code></li>
</ul></li>
<li>Enable authentication, change these settings in
<code>/etc/ssh/sshd_config</code>:

<ul>
<li><code>KerberosAuthentication yes</code></li>
<li><code>GSSAPIAuthentication yes</code></li>
<li><code>GSSAPICleanupCredentials yes</code></li>
<li><code>UsePAM no</code> <em># This is not supported by RHEL7 and should be left as <code>yes</code></em></li>
</ul></li>
<li>Restart <code>sshd</code>.</li>
</ol>

<h2>Configure OpenSSH clients</h2>

Configure <code>/etc/ssh_config</code> or <code>~/ssh/ssh_config</code>:

<pre><code>Host *.localnet
  GSSAPIAuthentication yes
  GSSAPIDelegateCredentials yes
</code></pre>
