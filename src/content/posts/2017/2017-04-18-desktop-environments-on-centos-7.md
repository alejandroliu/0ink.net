---
ID: "1082"
post_author: "2"
post_date: "2017-04-18 07:27:19"
post_date_gmt: "0000-00-00 00:00:00"
post_title: Desktop environments on Centos 7
post_excerpt: ""
post_status: draft
comment_status: open
ping_status: open
post_password: ""
post_name: ""
to_ping: ""
pinged: ""
post_modified: "2017-04-18 07:27:19"
post_modified_gmt: "2017-04-18 07:27:19"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1082
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Desktop environments on Centos 7
date: 2017-04-18
tags: desktop
revised: 2021-12-22
---

These are commands to install different Desktop environments
on Centos7

## Gnome

    yum groupinstall 'GNOME Desktop'

## KDE

    yum groupinstall "KDE Plasma Workspaces"

## Cinnamon

    yum install epel-release
    yum --enablerepo=epel install cinnamon

## MATE

    yum install epel-release
    yum --enablerepo=epel groupinstall "MATE Desktop"

## XFCE

    yum install epel-release
    yum --enablerepo=epel groupinstall XFCE

