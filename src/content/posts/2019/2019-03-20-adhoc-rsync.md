---
title: Ad-Hoc rsync daemons
date: 2019-03-20
tags: encryption, network, remote, scripts
revised: 2021-12-23
---

The other day I needed to copy a bunch of files between to servers
in my home network.  Because of the volume I wanted to copy the files
without having to go through `ssh`'s encryption overhead.  So I
figured I could use `netcat` for the data transport.

To do that I wrote these short scripts.

# Remote scripts

Copy these scripts on the remote server.  Make sure they are executable.

- Remote CLI

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=paraiso-light&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/adhoc-rsync/recv-nc"></script>

- Remote Helper script

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=paraiso-light&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/adhoc-rsync/recv"></script>

# Local scripts

Copy these scripts on the local server.  Make sure they are executable

- Local CLI

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=paraiso-light&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/adhoc-rsync/send"></script>


- Local Helper Script

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=paraiso-light&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/adhoc-rsync/send-nc"></script>

# Usage

Usage is fairly straight forward, on the remote server enter the
command:

```
./recv-nc
```

This will make remote listen for new client connects.  On the local
server, enter the command:

```
./send -avzr --delete --stats SRC/ remote:DST
```

Actually, just use whatever `rsync` options you need to use.  The `send`
script will include the `--rsh` option to make sure the helper
script gets executed.

# Issues

Unfortunately the local helper script does not detect that the transfer
has completed.  The remote helper script would finish correctly and
exit when the transfer is done.

You can simply press `Ctrl+C` to quit, or if you want to see any
summary stats, I would kill the running `cat` command.

Example:

```
$ bg
[2]+ ./send -avzr --stats SRC localhost:DST &
$ pidof cat
13143
$ kill 13143
$ Terminated

Number of files: 6 (reg: 5, dir: 1)
Number of created files: 0
Number of deleted files: 0
Number of regular files transferred: 0
Total file size: 5,869 bytes
Total transferred file size: 0 bytes
Literal data: 0 bytes
Matched data: 0 bytes
File list size: 0
File list generation time: 0.001 seconds
File list transfer time: 0.000 seconds
Total bytes sent: 202
Total bytes received: 17

sent 202 bytes  received 17 bytes  438.00 bytes/sec
total size is 5,869  speedup is 26.80
rsync error: syntax or usage error (code 1) at main.c(1189) [sender=3.1.3]
$
```

