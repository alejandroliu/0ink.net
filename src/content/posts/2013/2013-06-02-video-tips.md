---
ID: "475"
post_author: "2"
post_date: "2013-06-02 07:31:51"
post_date_gmt: "2013-06-02 07:31:51"
post_title: Media Tips
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: closed
post_password: ""
post_name: video-tips
to_ping: ""
pinged: ""
post_modified: "2013-06-02 07:31:51"
post_modified_gmt: "2013-06-02 07:31:51"
post_content_filtered: ""
post_parent: "0"
guid: http://s12.pw/wp/?p=126
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Media Tips
date: 2013-06-02
tags: feature
revised: 2021-12-22
---

This is an article about different media (and more specifically)
video files can be manipulated.

This is just for historical purposes as now almost everything can be
done using `ffmpeg` and the right options.

*   [libmp4v2](http://code.google.com/p/mp4v2/) contains:
    *   mp4art - to extract a picture (or coverart from mp4)
    *   mp4info - to get meta data from mp4 streams
    *   mp4tags - to set metadata and picture.
*   qt-fastload to move index to the front and making mp4 streamable
*   When encoding:
    *   Change max GOP or IDR to around 5 seconds.
    *   2-pass avg bitrate: 800 or even 500...

# Concatenating files:

## ffmpeg

ffmpeg has a feature concat, like

```
ffmpeg -i concat:"video1.ts|video2.ts"

```

There is also a "concat" video filter that may be useful. See
[http://ffmpeg.org/trac/ffmpeg/wiki/How%20to%20concatenate%20%28join,%20merge%29%20media%20files](http://ffmpeg.org/trac/ffmpeg/wiki/How%20to%20concatenate%20%28join,%20merge%29%20media%20files)

## gpac

An alternative is [gpac](http://gpac.wp.mines-telecom.fr/). One command
it includes is MP4Box to concatenate MP4s

```
mp4box -cat sbd0.mp4 -cat sbd1.mp4 -new sbd.mp4

```

## AviDemux

Of course the avidemux GUI can append files.

## Final notes

So far I have not been able to create a reliable media concat recipe.

# Media Gain

[mp3gain](http://mp3gain.sourceforge.net/) can be used to normalize
volume levels (without re-encoding). Accomplish this by using
[ReplayGain](http://en.wikipedia.org/wiki/ReplayGain) that needs to be
supported by player. (XBMC claims to supports this).
