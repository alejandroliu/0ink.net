---
title: Enable syslog with void
date: 2021-12-21
tags: desktop, directory, linux, service
revised: 2021-12-22
---

In [void][void] Linux, the default is without logging.  Most
cases it is OK for desktop use.

If you want to enable [syslog][log] service in [void][void],
you need to install:

```
socklog-void
```

Also to let your user have access to the logs, use:

```
usermod -aG socklog <your-username>
```

Because I like to have just a single directory for everything and use
`grep`, I do the following:

```
rm -rf /var/log/socklog/?*
mkdir /var/log/socklog/everything
ln -s socklog/everything/current /var/log/messages.log
```

Create the file `/var/log/socklog/everything/config` with these
contents:

```
+*
u<syslog-server-ip>:514
```

Enable daemons...

```
ln -s /etc/sv/socklog-unix /var/service/
ln -s /etc/sv/nanoklogd /var/service/
```

Reload `svlogd` (if it was already running)

```
killall -1 svlogd
```

# Reference:

- [voidlinux logging](https://docs.voidlinux.org/config/services/logging.html)


 [void]: https://voidlinux.org
 [log]: https://en.wikipedia.org/wiki/Syslog

