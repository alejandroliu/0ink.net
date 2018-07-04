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

<h2>Forcing either IPv4 or IPv6</h2>

This is for the scenario that you know which specific protocol works<br />
to reach a particular host. Usually good to eliminate the delay<br />
for SSH to figure out to switch IP protocols.

For IPv4:

<pre><code>ssh -4 user@hostname.com
</code></pre>

For IPv6

<pre><code>ssh -6 user@hostname.com
</code></pre>

<h2>Reuse a SSH connection</h2>

Rather than start a new TCP connection to a remote host, simply multiplex over an existing connection:

Add to your <code>~/.ssh/config</code> the following lines:

<pre><code>Host *
    ControlMaster auto
    ControlPath /tmp/%r@%h:%p
    ControlPersist 4h
# Another option for Control Path
    ControlPath ~/.ssh/%r@%h:%p
</code></pre>

<h2>Enable compression</h2>

Use the <code>-C</code> option. Or in the config file:

<pre><code>Compression yes
</code></pre>

<h2>Using cheaper cyphers</h2>

Using less computation-heavy ciphers in SSH, so that less time is spent during encryption/decryption. The default <strong>AES</strong> cipher used by OpenSSH is known to be slow.

An independent study shows that <strong>arcfour</strong> and <strong>blowfish</strong> ciphers are faster than <strong>AES</strong>. <strong>blowfish</strong> is a fast block cipher which is also very secure. Meanwhile, <strong>arcfour</strong> stream cipher is known to have vulnerabilities. So use caution when using <strong>arcfour</strong>.

Use the <code>-c blowfish-cbc,arcfour</code> option or in the config file:

<pre><code>Ciphers blowfish-cbc,arcfour
</code></pre>

<h2>Improve Session Persistence</h2>

<pre><code>ServerAliveInterval 60
ServerAliveCountMax 10
TCPKeepAlive no
</code></pre>

Counterintuitively, setting this results in fewer disconnections from your host, as transient TCP problems can self-repair in ways that fly below SSH's radar. You may not want to apply this to scripts that work via SSH, as "parts of the SSH tunnel going non-responsive" may work in ways you neither want nor expect!

