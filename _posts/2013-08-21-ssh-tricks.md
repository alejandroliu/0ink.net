---
ID: "646"
post_author: "2"
post_date: "2013-08-21 21:57:09"
post_date_gmt: "2013-08-21 21:57:09"
post_title: SSH Tricks
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: ssh-tricks
to_ping: ""
pinged: ""
post_modified: "2013-08-21 21:57:09"
post_modified_gmt: "2013-08-21 21:57:09"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=646
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: SSH Tricks
---

A bunch of stupid SSH tricks that can be useful somehow, somewhere...

Forcing either IPv4 or IPv6
---------------------------

This is for the scenario that you know which specific protocol works  
to reach a particular host. Usually good to eliminate the delay  
for SSH to figure out to switch IP protocols. For IPv4:

    ssh -4 user@hostname.com
    

For IPv6

    ssh -6 user@hostname.com
    

Reuse a SSH connection
----------------------

Rather than start a new TCP connection to a remote host, simply
multiplex over an existing connection: Add to your `~/.ssh/config` the
following lines:

    Host *
        ControlMaster auto
        ControlPath /tmp/%r@%h:%p
        ControlPersist 4h
    # Another option for Control Path
        ControlPath ~/.ssh/%r@%h:%p
    

Enable compression
------------------

Use the `-C` option. Or in the config file:

    Compression yes
    

Using cheaper cyphers
---------------------

Using less computation-heavy ciphers in SSH, so that less time is spent
during encryption/decryption. The default **AES** cipher used by
OpenSSH is known to be slow. An independent study shows that
**arcfour** and **blowfish** ciphers are faster than **AES**. 
**blowfish** is a fast block cipher which is also very secure.
Meanwhile, **arcfour** stream cipher is known to have vulnerabilities.
So use caution when using **arcfour**. Use the `-c blowfish-cbc,arcfour`
option or in the config file:

    Ciphers blowfish-cbc,arcfour
    

Improve Session Persistence
---------------------------

    ServerAliveInterval 60
    ServerAliveCountMax 10
    TCPKeepAlive no
    

Counterintuitively, setting this results in fewer disconnections from
your host, as transient TCP problems can self-repair in ways that fly
below SSH's radar. You may not want to apply this to scripts that work
via SSH, as "parts of the SSH tunnel going non-responsive" may work in
ways you neither want nor expect!
