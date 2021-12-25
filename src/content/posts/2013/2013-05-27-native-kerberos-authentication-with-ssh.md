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
tags: authentication, configuration, domain, information, login, network, password, service
---

This article is about integrating OpenSSH in a kerberos environment.
Allthough OpenSSH can provide passwordless logins (through Public/Private
keys), it is not a true SSO set-up.  This article makes use of
Kerberos TGT service to implement a true SSO configuration for OpenSSH.


# Pre-requisites

First off, you'll need to make sure that the OpenSSH server's Kerberos configuration (in `/etc/krb5.conf`) is correct and works, and that the server's keytab (typically `/etc/krb5.keytab`) contains an entry for `host/fqdn@REALM` (case-sensitive). I won't go into details on how this is done again; instead, I'll refer you to any one of the recent Kerberos-related articles (like [this one](http://blog.scottlowe.org/2006/08/08/linux-active-directory-and-windows-server-2003-r2-revisited/), [this one](http://blog.scottlowe.org/2006/08/15/solaris-10-and-active-directory-integration/), or [even this one](http://blog.scottlowe.org/2006/08/21/more-on-kerberos-authentication-against-active-directory/)). Just be sure that you can issue a `kinit -k host/fqdn@REALM` and get back a Kerberos ticket without having specify a password. (This tells you that the keytab is working as expected.)

# Configuring the SSH Server

Configure `/etc/ssh/sshd_config with the following:

```
 KerberosAuthentication yes
 KerberosTicketCleanup yes
 GSSAPIAuthentication yes
 GSSAPICleanupCredentials yes
 UseDNS yes
 UsePAM no

```

If `UseDNS` is set to `Yes`, the ssh server does a reverse host lookup to find the name of the connecting client. This is necessary when host-based authentication is used or when you want last login information to display host names rather than IP addresses. _Note:_ Some ssh sessions stall when performing reverse name lookups because the DNS servers are unreachable. If this happens, you can skip the DNS lookups by setting `UseDNS` to `no`. If `UseDNS` is not explicitly set in the `/etc/ssh/sshd_config` file, the default value is `UseDNS yes`.

# Configuring the SSH Client

Edit `/etc/ssh/ssh_config`, and change the file accordingly. For example, we want to enable Kerberos mechanism for all Hosts:

```
 Host *
      ....
      GSSAPIAuthentication yes
      GSSAPIDelegateCredentials yes

```

or to enable to specific domains:

```
Host *.example.com
  GSSAPIAuthentication yes
  GSSAPIDelegateCredentials yes

```

This limits GSSAPI authentication to only those hosts in the `example.com` domain. Modify the domain to be the appropriate domain for your network.

# Testing the Configuration

Obtain a valid Kerberos ticket `kinit username` from the command line. Once you have a ticket, you should be able to simply `ssh fqdn.of.server` and you will get logged in, without getting prompted for a password. If you get prompted for a password, go back and double-check your keytab, your SSH daemon configuration, and the time configuration on your OpenSSH server. Because Kerberos requires time synchronization, differences of greater than 5 minutes will cause the authentication to fail.
