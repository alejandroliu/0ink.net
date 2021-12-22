---
title: Mail Archiver ideas
date: 2017-03-10
tags: address, information
revised: 2021-12-22
---

We use it for receiving junk e-mails (i.e. for those times where we need an e-mail address for sign-up to a service).

E-mails are of the form:

ar-XXXX@0ink.net

## TODO:

Extend postie:

- http://postieplugin.com/extending/
- http://postieplugin.com/postie_post_before/

Before posting we insert all the header information into a table.

Automatically delete postings.  If we want to keep the post we change its category.

- https://wordpress.org/plugins/auto-prune-posts/

MAYBE: Markdownify it...

- https://github.com/Elephant418/Markdownify

EXTRA ARCHIVER:

- Check how gmail keeps folders (http://php.net/manual/en/function.imap-open.php)
And then see if we can hack it into Postie.
- https://www.electrictoolbox.com/open-mailbox-other-than-inbox-php-imap/
Maybe we do by e-mail@something/folder

http://postieplugin.com/forcing-an-email-check/

Would be the call back to MailGun

- Check if we can add MailGun to Postie
  - save transient when we start
  - Use event API to get message lists (since last transient)
  - Use message API to retrieve and delete messages

* E-mail archiving alternatives
    * [lurker ](http://lurker.sourceforge.net/)
    * [Enkive](https://www.enkive.org/)
    * [mboxpurge.pl](http://terminal.se/code.html)
    * [archivemail](http://archivemail.sourceforge.net/)
    * [Open Mail Archiva](https://sourceforge.net/projects/openmailarchiva/)
    * [GYB](http://git.io/gyb)
    * [gmvault](http://gmvault.org)
    * [Mail Piler](http://www.mailpiler.org/wiki/start)
