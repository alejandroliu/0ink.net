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
date: 2016-01-11
tags: authentication, config, configuration, directory, domain, integration, javascript, linux, login, password, service, settings
revised: 2021-12-22
---

This article goes over how to implement Single-Sign-On
on Linux.  It goes over the integration around
the Kerberos service and the applications, like for example
FireFox.

## Pre-requisites

*   Kerberos Domain Controller (KDC)
*   User accounts in the KDC
*   KDC based logins

To make sure that this is working, login to your workstation using your kerberos password and use the command:

    klist
    

This should show your principals assigned to you.

    Ticket cache: FILE:/tmp/krb5cc_XXXX_ErVb5X
    Default principal: zzzz@LOCALNET
    
    Valid starting       Expires              Service principal
    01/11/2016 15:51:35  01/12/2016 15:51:34  krbtgt/LOCALNET@LOCALNET
    

## Configuring Apache

1.  Install any necessary modules on the server:
    *   `yum install mod_auth_kerb`
2.  Create a service principal for the web server (this needs to be done on the KDC.
    *   `kadmin.local -q "addprinc -randkey HTTP/www.example.com`
3.  Export the encpryption keys to a keytab:
    *   `kadmin.local -q "ktadd -k /tmp/http.keytab HTTP/www.example.com`
4.  Copy `/tmp/http.keytab` to the webserver at `/etc/httpd/http.keytab`.
5.  Set ownership and permissions:
    *   `chmod 600 /etc/httpd/http.keytab`
    *   `chown apache /etc/httpd/http.keytab`
6.  Enable authentication, configure this:
    *   `AuthType Kerberos`
    *   `AuthName "Acme Corporation"`
    *   `KrbMethodNegotiate on`
    *   `KrbMethodK5Passwd off`
    *   `Krb5Keytab /etc/httpd/http.keytab`
    *   `require valid-user`
7.  Re-start apache

## Configure FireFox

1.  Navigate to `about:config`
2.  Search for: `negotiate-auth`
3.  Double click on `network.negotiate-auth.trusted-uris`.
4.  Enter hostname's, URL prefixes, etc, separated by commas. Examples:
    *   www.example.com
    *   http://www.example.com/
    *   .example.com

It is possible to configure this setting for all users by creating a global config file:

1.  Find configuration directory:
    *   `rpm -q firefox -l | grep preferences`
2.  Create a javascript file in that directory. (by convention, `autoconfig.js`; other file names will work, but for best results it should be early in the alphabet.)
3.  Add the following line:
    *   `pref("network.negotiate-auth.trusted-uris",".example.com");`

## Configure OpenSSH server

1.  Create a service principal for the host (this needs to be done on the KDC.
    *   `kadmin.local -q "addprinc -randkey host/shell.example.com`
2.  Export the encpryption keys to a keytab:
    *   `kadmin.local -q "ktadd -k /tmp/krb5.keytab host/shell.example.com`
3.  Copy `/tmp/krb5.keytab` to the host at: `/etc/krb5.keytab`.
4.  Set ownership and permissions:
    *   `chmod 600 /etc/krb5.keytab`
    *   `chown root /etc/krb5.keytab`
5.  Enable authentication, change these settings in `/etc/ssh/sshd_config`:
    *   `KerberosAuthentication yes`
    *   `GSSAPIAuthentication yes`
    *   `GSSAPICleanupCredentials yes`
    *   `UsePAM no` _\# This is not supported by RHEL7 and should be left as `yes`_
6.  Restart `sshd`.

## Configure OpenSSH clients


Configure `/etc/ssh_config` or `~/ssh/ssh_config`:

    Host *.localnet
      GSSAPIAuthentication yes
      GSSAPIDelegateCredentials yes
