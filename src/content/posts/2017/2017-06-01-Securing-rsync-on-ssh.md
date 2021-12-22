---
ID: "1089"
post_author: "2"
post_date: "2017-06-01 12:06:30"
post_date_gmt: "0000-00-00 00:00:00"
post_title: Securing rsync on ssh
post_excerpt: ""
post_status: draft
comment_status: open
ping_status: open
post_password: ""
post_name: ""
to_ping: ""
pinged: ""
post_modified: "2017-06-01 12:06:30"
post_modified_gmt: "2017-06-01 12:06:30"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1089
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Securing rsync on ssh
date: 2017-06-01
tags: backup, directory, remote, security
revised: 2021-12-22
---

Reference: [positon.org](http://positon.org/rsync-command-restriction-over-ssh)

You have 2 systems and you want to set up a secure backup with rsync + SSH of one system to the other.

Very simply, you can use:

```
backup.example.com# rsync -avz --numeric-ids --delete root@myserver.example.com:/path/ /backup/myserver/
```

To do the backup, you have to be root on the remote server, because some files are only root readable.

Problem: you will allow backup.example.com to do anything on myserver.example.com, where just read only access on the directory is sufficient.

To solve it, you can use the command="" directive in the authorized_keys file to filter the command.

To find this command, start rsync adding the -e'ssh -v' option:

```
rsync -avz -e'ssh -v' --numeric-ids --delete root@myserver.example.com:/path/ /backup/myserver/ 2>&1 | grep "Sending command"
```

You get a result like:

```
debug1: Sending command: rsync --server --sender -vlogDtprze.iLsf --numeric-ids . /path/
```

Now, just add the command before the key in /root/.ssh/authorized_keys:

```
command="rsync --server --sender -vlogDtprze.iLsf --numeric-ids . /path/" ssh-rsa AAAAB3NzaC1in2EAAAABIwAAABio......
```

And for even more security, you can add an IP filter, and other options:

```
from="backup.example.com",command="rsync --server --sender -vlogDtprze.iLsf --numeric-ids . /path/",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ssh-rsa AAAAB3NzaC1in2EAAAABIwAAABio......
```

Now try to open a ssh shell on the remote server.. and try some unauthorized rsync commands...
*Notes:*

* Beware that if you change rsync command options, change also the authorized_keys file.
* No need for complex chroot anymore.

See also:

* man ssh #/AUTHORIZED_KEYS FILE FORMAT
* man rsync
* view /usr/share/doc/rsync/scripts/rrsync.gz (restricted rsync, allows you to manage allowed options precisely)


