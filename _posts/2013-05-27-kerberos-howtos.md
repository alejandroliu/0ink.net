---
ID: "350"
post_author: "2"
post_date: "2013-05-27 10:22:00"
post_date_gmt: "2013-05-27 10:22:00"
post_title: Kerberos howtos
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: kerberos-howtos
to_ping: ""
pinged: ""
post_modified: "2013-05-27 10:22:00"
post_modified_gmt: "2013-05-27 10:22:00"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=350
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Kerberos howtos
---

Kerberos is a network authentication protocol which works on the basis
of "tickets" to allow nodes communicating over a non-secure network to
prove their identity to one another in a secure manner. (Source
[Kerberos_(protocol)](http://en.wikipedia.org/wiki/Kerberos_(protocol)) )

# Backups

Create backup:

```
kdb5_util dump _dump_file_

```

Restore from dump file:

```
kdb5_util load _dump_file_

```

# Master/Slave replication

Initial set-up:

```
(master)# kdb5_util dump _dump_file_
(master)# kprop -d -f _dump_file_ _slave_

```

In `crontab` on master:

```
krb5_util dump _dump_file_
kprop -f _dump_file_ _slave_

```

# kadmin command

From command line:

```
kadmin.local -q 'cmd'

```

*   listprincs - list principals
*   ank _principal_ \- new principal (input: password)
*   delprinc _principal_ \- delete principal (input: yes/no)
*   ank -randkey host/_fqdn_@REALM - create a service key
*   ktadd -k _filename_ host/_fqdn_@REALM export key to keytab file.

Save keytab in `/etc/krb5.keytab` and

```
chown root:root /etc/krb5.keytab
chmod 400 /etc/krb5.keytab

```

# Logging

To turn logging on, add this section to `/etc/krb5.conf` (adapt the
file paths to your likings):

```
 [logging]
     default = FILE:/var/log/krb5.log
     kdc = FILE:/var/log/krb5kdc.log
     admin_server = FILE:/var/log/kadmind.log

```

# Merging (or editing) a keytab file

Merging or editing keytabs is done through the **ktutil** command.
Suppose we have two keytabs, keytab1 and keytab2, each having their own
set of keys, and we would like to merge the two keytabs in one (or
create a new keytab containing specific keys). The operation is done
through the **ktutil** shell, with **rkt** and **write_kt** commands,
and optionally **delent** if you want to delete some entities. Example:

```
 # ktutil

```

Read content of keytab1:

```
 ktutil: rkt keytab1
 ktutil: list
 slot KVNO Principal
 ---- ---- -------------------------------------------------------------
 1 3 <principal and key of keytab1>
 2 3 <principal and key of keytab1>

```

Now, we will read the content of keytab2:

```
 ktutil: rkt keytab2
 ktutil: list
 slot KVNO Principal
 ---- ---- -----------------------------------------------------------
 1 3 <principal and key of keytab1>
 2 3 <principal and key of keytab1>
 3 2 <principal and key of keytab2>
 4 2 <principal and key of keytab2>

```

Save this content in a temporary keytab:

```
 ktutil: write_kt /tmp/krb5.keytab

```

This utility is used to duplicate and tweak keytab entries (as its
name implies), and remove the need of exporting the keys out of the KDC
twice or more (simultaneously avoiding KVNO's increment).

# OpenWRT recipes

## Packages

### Server

*   `krb5-server`
    *   `krb5-libs` (dependency of **krb5-server**)

### Client

*   `krb5-client`

## Configuration

Create the file `/etc/krb5.conf` with the following credentials. Example:

```
[libdefaults]
    default_realm = YOURDOMAIN.ORG
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    forwardable = yes

[realms]
    YOURDOMAIN.ORG = {
        kdc = server_address_of_this_machine:88
        admin_server = server_address_of_this_machine:749
        default_domain = yourdomain.org
    }

[domain_realm]
    .yourdomain.org = YOURDOMAIN.ORG
    yourdomain.org = YOURDOMAIN.ORG

```

Replace `YOURDOMAIN.ORG` / `yourdomain.org` with the domain name of
your domain the server should act for (names must be specified in
UPPER- / lowercase as shown above). Replace `server_address_of_this_machine`
with the host name/IP adress of this server you're setting up.

### Starting the server

Start the server by issuing

```
/etc/init.d/krb5kdc start

```

This should create the `/etc/krb5kdc/` directory with the following files

```
-rw-------    1 root     root         8192 Feb 13 11:17 principal
-rw-------    1 root     root         8192 Feb 13 09:12 principal.kadm5
-rw-------    1 root     root            0 Feb 13 09:12 principal.kadm5.lock
-rw-------    1 root     root            0 Feb 13 11:17 principal.ok

```

In case you don't get any error messages check your server by logging
on with `kadmin.local` In case everything works well you will see the
following message

```
root@bridge:~# kadmin.local
Authenticating as principal xxxxxxx/admin@YOURDOMAIN.ORG with password.
kadmin.local:

```

### Start on boot

To enable/disable automatic start on boot:

```
/etc/init.d/krb5kdc enable

```

this simply creates a symlink: `/etc/rc.d/S60krb5kdc` ? `/etc/init.d/krb5kdc`

```
/etc/init.d/krb5kdc disable

```

this removes the symlink again

# References

See Also:

*   [http://www.kerberos.org/software/adminkerberos.pdf](http://www.kerberos.org/software/adminkerberos.pdf)  
    Refer to pages 16/17 for testing procedures.
