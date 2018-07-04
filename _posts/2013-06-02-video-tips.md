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

---

<ul>
<li><a href="http://code.google.com/p/mp4v2/">libmp4v2</a> contains: 

<ul>
<li>mp4art - to extract a picture (or coverart from mp4)</li>
<li>mp4info - to get meta data from mp4 streams</li>
<li>mp4tags - to set metadata and picture.</li>
</ul></li>
<li>qt-fastload to move index to the front and making mp4 streamable</li>
<li>When encoding: 

<ul>
<li>Change max GOP or IDR to around 5 seconds.</li>
<li>2-pass avg bitrate: 800 or even 500...</li>
</ul></li>
</ul>

<h1>Concatenating files:</h1>

<h2>ffmpeg</h2>

ffmpeg has a feature concat, like

<pre><code>ffmpeg -i concat:"video1.ts|video2.ts"
</code></pre>

There is also a "concat" video filter that may be useful.

See <a href="http://ffmpeg.org/trac/ffmpeg/wiki/How%20to%20concatenate%20%28join,%20merge%29%20media%20files">http://ffmpeg.org/trac/ffmpeg/wiki/How%20to%20concatenate%20%28join,%20merge%29%20media%20files</a>

<h2>gpac</h2>

An alternative is <a href="http://gpac.wp.mines-telecom.fr/">gpac</a>.  One command it includes is MP4Box to concatenate MP4s

<pre><code>mp4box -cat sbd0.mp4 -cat sbd1.mp4 -new sbd.mp4
</code></pre>

<h2>AviDemux</h2>

Of course the avidemux GUI can append files.

<h2>Final notes</h2>

So far I have not been able to create a reliable media concat recipe.

<h1>Media Gain</h1>

<a href="http://mp3gain.sourceforge.net/">mp3gain</a> can be used to normalize volume levels (without re-encoding).  Accomplish this by using <a href="http://en.wikipedia.org/wiki/ReplayGain">ReplayGain</a> that needs to be supported by player.  (XBMC claims to supports this).

