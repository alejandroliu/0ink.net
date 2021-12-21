---
ID: "999"
post_author: "2"
post_date: "2016-11-14 13:21:48"
post_date_gmt: "2016-11-14 13:21:48"
post_title: MariaDB Quickest Quick start
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: mariadb-quickest-quick-start
to_ping: ""
pinged: ""
post_modified: "2017-03-12 12:02:04"
post_modified_gmt: "2017-03-12 12:02:04"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=999
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: MariaDB Quickest Quick start
date: 2016-11-14
---

This article outlines the bare minimum to get
a MariaDB or MySQL database up and running.

It covers a CentOS/RHEL and an ArchLinux installs.

Make sure your system is up to date:

| CentOS/RHEL | ArchLinux |
|-------------|-----------|
| `yum update -y` | `pacman -Syu` |

Install the software:

| CentOS/RHEL | ArchLinux |
|-------------|-----------|
| `yum install mariadb-server` | `pacman -S mariadb` |
| | `mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql` |

Start the database service:

     systemctl start mariadb

Check if it is running:

     systemctl is-active mariadb.service
     systemctl status mariadb

The following step is optional but highly recommended:

     mysql_secure_installation

Enable database to start on start-up:

     systemctl enable mariadb

Enter SQL:

     mysql -u root -p

Creating database:

     create database bugzilla;
     FLUSH PRIVILEGES;

Create user:

     GRANT ALL PRIVILEGES ON bugzilla.* TO 'warren'@'localhost' IDENTIFIED BY 'mypass';
     GRANT ALL PRIVILEGES ON killrate.* TO 'pocketmine'@'%' IDENTIFIED BY 'mypass';
     FLUSH PRIVILEGES;


