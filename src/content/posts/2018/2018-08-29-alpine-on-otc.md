---
title: Alpine on OTC
tags: alpine, linux
---

These are just random thoughts nothing really was implemented.

Alpine Linux image

- preparation: jq and other deps to `/apks/x86_64`

- `/etc/local.d/`
    `cloud-init-lite`

0. if `/etc/network/intefaces` exists we abort
1. `apk add --force-non-repository /path oniguruma,jq` .. restore `/etc/apk/world`
2. `udhcpc -b -p /var/run/udhcpc.eth0.pid -i eth0`
3. install `openssh` and start it
4. `wget` meta data and create `/root/.ssh/authorized_keys`
  - `wget -O- http://169.254.169.254/openstack/YYYY-MM-DD/meta_data.json`



