---
ID: "376"
post_author: "2"
post_date: "2013-05-27 12:05:08"
post_date_gmt: "2013-05-27 12:05:08"
post_title: Native Kerberos Authentication with SSH
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: native-kerberos-authentication-with-ssh
to_ping: ""
pinged: ""
post_modified: "2013-05-27 12:05:08"
post_modified_gmt: "2013-05-27 12:05:08"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=376
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Native Kerberos Authentication with SSH
...
---

<h1>Pre-requisites</h1>

First off, you'll need to make sure that the OpenSSH server's Kerberos configuration (in <code>/etc/krb5.conf</code>) is correct and works, and that the server's keytab (typically <code>/etc/krb5.keytab</code>) contains an entry for <code>host/fqdn@REALM</code> (case-sensitive). I won't go into details on how this is done again; instead, I'll refer you to any one of the recent Kerberos-related articles (like <a href="http://blog.scottlowe.org/2006/08/08/linux-active-directory-and-windows-server-2003-r2-revisited/">this one</a>, <a href="http://blog.scottlowe.org/2006/08/15/solaris-10-and-active-directory-integration/">this one</a>, or <a href="http://blog.scottlowe.org/2006/08/21/more-on-kerberos-authentication-against-active-directory/">even this one</a>). Just be sure that you can issue a <code>kinit -k host/fqdn@REALM</code> and get back a Kerberos ticket without having specify a password. (This tells you that the keytab is working as expected.)

<h1>Configuring the SSH Server</h1>

Configure `/etc/ssh/sshd_config with the following:

<pre><code> KerberosAuthentication yes
 KerberosTicketCleanup yes
 GSSAPIAuthentication yes
 GSSAPICleanupCredentials yes
 UseDNS yes
 UsePAM no
</code></pre>

If <code>UseDNS</code> is set to <code>Yes</code>, the ssh server does a reverse host lookup to find the name of the connecting client. This is necessary when host-based authentication is used or when you want last login
information to display host names rather than IP addresses.

<em>Note:</em> Some ssh sessions stall when performing reverse name lookups because the DNS servers are unreachable. If this happens, you can skip the DNS lookups by setting <code>UseDNS</code> to <code>no</code>. If <code>UseDNS</code> is not explicitly set in the <code>/etc/ssh/sshd_config</code> file, the default value is <code>UseDNS yes</code>.

<h1>Configuring the SSH Client</h1>

Edit <code>/etc/ssh/ssh_config</code>, and change the file accordingly. For
example, we want to enable Kerberos mechanism for all Hosts:

<pre><code> Host *
      ....
      GSSAPIAuthentication yes
      GSSAPIDelegateCredentials yes
</code></pre>

or to enable to specific domains:

<pre><code>Host *.example.com
  GSSAPIAuthentication yes
  GSSAPIDelegateCredentials yes
</code></pre>

This limits GSSAPI authentication to only those hosts in the <code>example.com</code> domain. Modify the domain to be the appropriate domain for your network.

<h1>Testing the Configuration</h1>

Obtain a valid Kerberos ticket <code>kinit username</code> from the command line.

Once you have a ticket, you should be able to simply <code>ssh fqdn.of.server</code> and you will get logged in, without getting prompted for a password. If you get prompted for a password, go back and double-check your keytab, your SSH daemon configuration, and the time configuration on your OpenSSH server. Because Kerberos requires time synchronization, differences of greater than 5 minutes will cause the authentication to fail.

