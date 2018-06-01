---
ID: "942"
post_author: "2"
post_date: "2015-12-04 20:06:54"
post_date_gmt: "2015-12-04 20:06:54"
post_title: Let's Encrypt
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: lets-encrypt
to_ping: ""
pinged: ""
post_modified: "2015-12-04 20:06:54"
post_modified_gmt: "2015-12-04 20:06:54"
post_content_filtered: ""
post_parent: "0"
guid: http://0ink.net/wp/?p=942
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Let's Encrypt
...
---

This is a service that let's you get SSL certificates for HTTPS.  These certificates are trusted by major browsers.

See <a href="https://letsencrypt.org/about/">Let's Encrypt</a>

This is a barebones <em>howto</em> to get SSL certificates:

<pre><code>git clone https://github.com/letsencrypt/letsencrypt
cd letsencrypt
</code></pre>

This contains the client software for let's encrypt.

<pre><code>./letsencrypt-auto certonly --manual
</code></pre>

This will start by updating and getting any needed dependencies and then jump to a <em>wizard</em>
like configuration to get this done.  Follow the prompts and pay special attention on the
prompt used to validate your domain.  (You need to create a couple of folders and a file
with the right content).

Afterwards your certificates will be in:

<pre><code>/etc/letsencrypt/live/mydomain.tld
</code></pre>

Then go to your CPanel configuration, then upload:

<ul>
<li><code>privkey.pem</code> to <strong>Private Keys</strong></li>
<li><code>cert.pem</code> to <strong>Certificates</strong></li>
</ul>

Then you go to <strong>Manage SSL Hosts -&gt; Browse Certificates</strong>, pick the right certificate.  Then paste <code>chain.pem</code> (from /etc/letsencrypt/live/mydomain.tld) to the CA Bundle box.
