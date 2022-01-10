---
ID: "140"
post_author: "2"
post_date: "2016-10-29 08:15:30"
post_date_gmt: "2016-10-29 08:15:30"
post_title: Hosting WordPress on OpenShift
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: hosting-wordpress-on-openshift
to_ping: ""
pinged: ""
post_modified: "2016-10-29 21:53:01"
post_modified_gmt: "2016-10-29 21:53:01"
post_content_filtered: ""
post_parent: "0"
guid: https://alejandro.iliu.net/?p=140
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Hosting WordPress on OpenShift
tags: backups, cloud, database, drive, github, integration, scripts, storage, wordpress
---

![openshift]({static}/images/2016/img_0423.jpg)

So I finally moved my WordPress web sites to OpenShift.

OpenShift is a cloud based Platform-as-a-Service offering from RedHat.   And while there is a learning curve I would say that so far it works great.

My implementation is a fully cloud based solution. Makes use of the following services:

*   GitHub for code hosting
*   Travis-CI for continuous integration.
*   OpenShift (with autoscaling) for the database and web server
*   CloudFlare
*   Sirv.com for image hosting
*   Facebook and G+ integration
*   Google drive for cloud backups

All the code can be examined on GitHub.

For the WordPress hosting I started with the OpenShift WordPress QuickStart and added scripts to deploy directly from Github to OpenShift via Travis.

Actually Travis has that functionality built in but it was a little quirky for my use cases so I wrote my own.

On the OpenShift side, I added code to download add-ons (plugins and themes) automatically and to deploy from the same repo to multiple apps.

The rationale for this is to get addons installed automatically in the
event of autoscaling while keeping the github commit log fairly tidy.

Also created a couple of Wordpress plugins to:

*   Misc shortcodes and stuff
*   Automatically upload pictures to an S3 cloud storage (sivr.com in my case but this is configurable)
