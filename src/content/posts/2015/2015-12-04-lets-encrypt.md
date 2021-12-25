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
tags: configuration, domain, encryption, git, service, software
---

This is a service that let's you get SSL certificates for HTTPS. These certificates are trusted by major browsers. See [Let's Encrypt](https://letsencrypt.org/about/) This is a barebones _howto_ to get SSL certificates:

    git clone https://github.com/letsencrypt/letsencrypt
    cd letsencrypt
    

This contains the client software for let's encrypt.

    ./letsencrypt-auto certonly --manual
    

This will start by updating and getting any needed dependencies and then jump to a _wizard_ like configuration to get this done. Follow the prompts and pay special attention on the prompt used to validate your domain. (You need to create a couple of folders and a file with the right content). Afterwards your certificates will be in:

    /etc/letsencrypt/live/mydomain.tld
    

Then go to your CPanel configuration, then upload:

*   `privkey.pem` to **Private Keys**
*   `cert.pem` to **Certificates**

Then you go to **Manage SSL Hosts -> Browse Certificates**, pick the right certificate. Then paste `chain.pem` (from /etc/letsencrypt/live/mydomain.tld) to the CA Bundle box.
