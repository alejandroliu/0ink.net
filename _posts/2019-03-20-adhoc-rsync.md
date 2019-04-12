---
title: Ad-Hoc rsync daemons
---

The other day I needed to copy a bunch of files between to servers
in my home network.  Because of the volume I wanted to copy the files
without having to go through `ssh`'s encryption overhead.  So I
figured I could use `netcat` for the data transport.

To do that I wrote these short scripts.

# Server scripts

* * *
 

<!--
  <script src="https://gist-it.appspot.com/https://github.com/TortugaLabs/void-utils/raw/master/kernel/mkmenu.sh?footer=minimal"></script>
-->

