---
title: Alpine Boot
date: "2025-01-23"
author: alex
tags: alpine, linux, scripts, service
---
This is a quick note.  In Alpine linux you can run start-up scripts by enabling the
`local` service:

```bash
rc-update add local default
```

When this is enabled, it will run all executable scripts that end with `.start` on
start-up and scripts that end with `.stop` on shutdown.

By default, these scripts would run silently and you will see:

```text
* Starting local ... [ ok ] 
```

during boot-up if things went well.  If there was an error you would see:

```text
* Starting local ... [ !! ] 
```

To see more details on what happened create the file `/etc/conf.d/local` with
the following:

```bash
# /etc/conf.d/local
rc_verbose=yes
```

