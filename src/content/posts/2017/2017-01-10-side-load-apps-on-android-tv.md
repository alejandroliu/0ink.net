---
ID: "1021"
post_author: "2"
post_date: "2017-01-10 16:31:41"
post_date_gmt: "2017-01-10 16:31:41"
post_title: Side Load apps on Android TV
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: side-load-apps-on-android-tv
to_ping: ""
pinged: ""
post_modified: "2017-01-10 16:31:41"
post_modified_gmt: "2017-01-10 16:31:41"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1021
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "1"
title: Side Load apps on Android TV
date: 2017-01-10
tags: android, browser, cloud, drive, manager, settings, storage
revised: 2021-12-22
---

So we bough a Philips 50PFK6540.  This is a 50" TV with
[Ambi Ligh](https://en.wikipedia.org/wiki/Ambilight) and
[Android TV](https://en.wikipedia.org/wiki/Android_TV).

One of the things I wanted to do from the very start was to load my own APKs.  This was not
possible until a recent (2016) update that enabled the **"Install from Unknown Sources"**
setting option.

This made it possible to side load applications.  However, things are not as easy as I
initially thought.  Because while installing from unknown sources was possible, you can not
do this from the built-in browser.  So the procedure is as folows:

1. Go to settings to enable **Install from Unknown sources**, which should be under
   `Security &amp; Restrictions`.
2. Download [ES File Explorer](https://play.google.com/store/apps/details?id=com.estrongs.android.pop)
   from the Play Store.  A bit of a warning: on phones and tablets, ES File Explorer isn't something
   that is generally recommended as it used to be a reliable file manager that was one of the
   most valuable Android apps, but recently it became riddled with ads *many of which are highly
   intrusive) leading many users to uninstall it and websites to remove it from their *must have* lists.
   Fortunately, the Android TV app seems to have gone largely untouched by this, so it still is
   recommended it for the purpose of this tutorial.
3. Use ES File Explorer to download the APK you want to side load.  There is a number of ways to do
   this.  I used the built-in FTP server.  But you could use any method (i.e Thumb drive, Cloud
   Storage, etc...)
4. Open the APK from ES File Explorer and install it.

![Philips 50PFK6540](/images/2017/50PFK6540_12-IMS-nl_NL.png)


