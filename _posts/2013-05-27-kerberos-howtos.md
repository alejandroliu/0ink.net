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

Kerberos is a network authentication protocol which works on the basis of "tickets" to allow nodes communicating over a non-secure network to prove their identity to one another in a secure manner. (Source <a href="http://en.wikipedia.org/wiki/Kerberos_(protocol)">Kerberos_(protocol)</a> )

<h1>Backups</h1>

Create backup:

<pre><code>kdb5_util dump _dump_file_
</code></pre>

Restore from dump file:

<pre><code>kdb5_util load _dump_file_
</code></pre>

<h1>Master/Slave replication</h1>

Initial set-up:

<pre><code>(master)# kdb5_util dump _dump_file_
(master)# kprop -d -f _dump_file_ _slave_
</code></pre>

In <code>crontab</code> on master:

<pre><code>krb5_util dump _dump_file_
kprop -f _dump_file_ _slave_
</code></pre>

<h1>kadmin command</h1>

From command line:

<pre><code>kadmin.local -q 'cmd'
</code></pre>

<ul>
<li>listprincs - list principals</li>
<li>ank <em>principal</em> - new principal (input: password)</li>
<li>delprinc <em>principal</em> - delete principal (input: yes/no)</li>
<li>ank -randkey host/<em>fqdn</em>@REALM - create a service key</li>
<li>ktadd -k <em>filename</em> host/<em>fqdn</em>@REALM export key to keytab file.</li>
</ul>

Save keytab in <code>/etc/krb5.keytab</code> and

<pre><code>chown root:root /etc/krb5.keytab
chmod 400 /etc/krb5.keytab
</code></pre>

<h1>Logging</h1>

To turn logging on, add this section to <code>/etc/krb5.conf</code> (adapt the file paths to your likings):

<pre><code> [logging]
     default = FILE:/var/log/krb5.log
     kdc = FILE:/var/log/krb5kdc.log
     admin_server = FILE:/var/log/kadmind.log
</code></pre>

<h1>Merging (or editing) a keytab file</h1>

Merging or editing keytabs is done through the <strong>ktutil</strong> command. Suppose we have two keytabs, keytab1 and keytab2, each having their own set of keys, and we would like to merge the two keytabs in one (or create a new keytab containing specific keys). The operation is done through the <strong>ktutil</strong> shell, with <strong>rkt</strong> and <strong>write_kt</strong> commands, and optionally <strong>delent</strong> if you want to delete some
entities.

Example:

<pre><code> # ktutil
</code></pre>

Read content of keytab1:

<pre><code> ktutil: rkt keytab1
 ktutil: list
 slot KVNO Principal
 ---- ---- -------------------------------------------------------------
 1 3 &lt;principal and key of keytab1&gt;
 2 3 &lt;principal and key of keytab1&gt;
</code></pre>

Now, we will read the content of keytab2:

<pre><code> ktutil: rkt keytab2
 ktutil: list
 slot KVNO Principal
 ---- ---- -----------------------------------------------------------
 1 3 &lt;principal and key of keytab1&gt;
 2 3 &lt;principal and key of keytab1&gt;
 3 2 &lt;principal and key of keytab2&gt;
 4 2 &lt;principal and key of keytab2&gt;
</code></pre>

Save this content in a temporary keytab:

<pre><code> ktutil: write_kt /tmp/krb5.keytab
</code></pre>

This utility is used to duplicate and tweak keytab entries (as its
name implies), and remove the need of exporting the keys out of the KDC
twice or more (simultaneously avoiding KVNO's increment).

<h1>OpenWRT recipes</h1>

<h2>Packages</h2>

<h3>Server</h3>

<ul>
<li><code>krb5-server</code>

<ul>
<li><code>krb5-libs</code> (dependency of <strong>krb5-server</strong>)</li>
</ul></li>
</ul>

<h3>Client</h3>

<ul>
<li><code>krb5-client</code></li>
</ul>

<h2>Configuration</h2>

Create the file <code>/etc/krb5.conf</code> with the following credentials. Example:

<pre><code>[libdefaults]
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
</code></pre>

Replace <code>YOURDOMAIN.ORG</code> / <code>yourdomain.org</code> with the domain name of your domain the server should act for (names must be specified in UPPER- / lowercase as shown above). Replace <code>server_address_of_this_machine</code> with the host name/IP adress of this server you're setting up.

<h3>Starting the server</h3>

Start the server by issuing

<pre><code>/etc/init.d/krb5kdc start
</code></pre>

This should create the <code>/etc/krb5kdc/</code> directory with the following files

<pre><code>-rw-------    1 root     root         8192 Feb 13 11:17 principal
-rw-------    1 root     root         8192 Feb 13 09:12 principal.kadm5
-rw-------    1 root     root            0 Feb 13 09:12 principal.kadm5.lock
-rw-------    1 root     root            0 Feb 13 11:17 principal.ok
</code></pre>

In case you don't get any error messages check your server by logging on with
<code>kadmin.local</code>

In case everything works well you will see the following message

<pre><code>root@bridge:~# kadmin.local
Authenticating as principal xxxxxxx/admin@YOURDOMAIN.ORG with password.
kadmin.local:
</code></pre>

<h3>Start on boot</h3>

To enable/disable automatic start on boot:

<pre><code>/etc/init.d/krb5kdc enable
</code></pre>

this simply creates a symlink: <code>/etc/rc.d/S60krb5kdc</code> ? <code>/etc/init.d/krb5kdc</code>

<pre><code>/etc/init.d/krb5kdc disable
</code></pre>

this removes the symlink again

<h1>References</h1>

See Also:

<ul>
<li><a href="http://www.kerberos.org/software/adminkerberos.pdf">http://www.kerberos.org/software/adminkerberos.pdf</a><br />
Refer to pages 16/17 for testing procedures.</li>
</ul>
