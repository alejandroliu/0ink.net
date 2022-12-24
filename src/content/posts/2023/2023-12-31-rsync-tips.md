---
title: Rsync-tips
tags: backups
---
- snapshot style backups
- using filters
- securing access

Links 

- https://stackoverflow.com/questions/50706415/trouble-in-understanding-use-chroot-parameter-in-rsyncd-conf
- https://sites.google.com/site/rsync2u/home/rsync-tutorial/how-rsync-works3
- https://linuxconfig.org/how-to-setup-the-rsync-daemon-on-linux
- https://www.atlantic.net/vps-hosting/how-to-setup-rsync-daemon-linux-server/
- [rsync](http://linuxcommand.org/man_pages/rsync1.html) man page
  - Another [Config  Tutorial](http://www.fatdex.net/php/2013/05/20/how-to-turn-a-dlink-dns-323-into-a-rsync-backup-location/)  
  - Configure [rsync daemon](http://www.jveweb.net/en/archives/2011/01/running-rsync-as-a-daemon.html)

Here is how the "rsync --link-dest=DIR" algorithm creates files in destination:

```
    if destination does not exists,
        create destination

    if DIR exists (where DIR is the previous backup),
        compare source to DIR
        hard link unchanged files to DIR
        copy changed files from source
    else
        copy all files from source
```

By default, rsync does not compressed files.  Restoring files is as simple as a cp command.



