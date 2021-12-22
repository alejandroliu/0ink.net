---
ID: "1065"
post_author: "2"
post_date: "2017-03-24 10:52:26"
post_date_gmt: "0000-00-00 00:00:00"
post_title: Build a VR app in 15 minutes
post_excerpt: ""
post_status: draft
comment_status: open
ping_status: open
post_password: ""
post_name: ""
to_ping: ""
pinged: ""
post_modified: "2017-03-24 10:52:26"
post_modified_gmt: "2017-03-24 10:52:26"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1065
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Build a VR app in 15 minutes
date: 2018-06-18
tags: application, browser, desktop, directory, git, github
revised: 2021-12-22
---

In 15 minutes, you can develop a virtual reality application and run
it in a web browser, on a VR headset, or with [Google Daydream](https://vr.google.com/daydream/).
The key is [A-Frame](https://aframe.io/), an open source toolkit built
by the [Mozilla VR Team](https://mozvr.com/).

## Test It

Open [this link](https://theta360developers.github.io/360gallery/)
using Chrome or Firefox on your mobile phone.

Put your phone into [Google Cardboard](https://vr.google.com/cardboard/)
and stare at a menu square to switch the 360-degree scene.

![vr-in-15mins-1](/images/2018/vr-in-15min-1.png)

## Fork it

Fork the [sample repository from GitHub](https://github.com/theta360developers/360gallery).
Change directory into the repo.

![vr-in-15mins-2](/images/2018/vr-in-15min-2.png)

If you have 360-degree images, you can drop them into the img/
sub-directory. If you don't have 360-degree images, you can get
started with the open source [Hugin](http://hugin.sourceforge.net/)
panorama photo stitcher. The boilerplate app includes [RICOH THETA media](http://theta360.guide/community-document/community.html)
I took at a meetup in San Francisco.

## Create thumbnails

The menus in the headset are standard images that are 240x240 pixels.
A-Frame handles the perspective shifts for you automatically.

![vr-in-15mins-3](/images/2018/vr-in-15min-3.png)

## Edit code

If you use the same image file names and overwrite 1.jpg in /img, you
do not need to edit the code at all. If you want to extend the program
or modify it with your own filenames, change the id and the src in
index.html to match your files.

```
<body>
  <a-scene>
    <a-assets>
      <img id="kieran" src="img/1.jpg">
      <img id="kieran-thumb" crossorigin="anonymous" src="img/kieran-thumb.png">
      <img id="christian-thumb" crossorigin="anonymous" src="img/christian-thumb.png">
      <img id="eddie-thumb" crossorigin="anonymous" src="img/eddie-thumb.png">
      <audio id="click-sound" crossorigin="anonymous" src="https://cdn.aframe.io/360-image-gallery-boilerplate/audio/click.ogg"></audio>
      <img id="christian" crossorigin="anonymous" src="img/2.jpg">
      <img id="eddie" crossorigin="anonymous" src="img/4.jpg">
```

Scroll down and edit the section for the menu links.

```
<!-- 360-degree image. -->
<a-sky id="image-360" radius="10" src="#kieran"></a-sky>

<!-- Image links. -->
<a-entity id="links" layout="type: line; margin: 1.5" position="0 -1 -4">
  <a-entity template="src: #link" data-src="#christian" data-thumb="#christian-thumb"></a-entity>
  <a-entity template="src: #link" data-src="#kieran" data-thumb="#kieran-thumb"></a-entity>
  <a-entity template="src: #link" data-src="#eddie" data-thumb="#eddie-thumb"></a-entity>
</a-entity>
```

## Upload to GitHub pages

Add and commit your changes:

```
git add *
git commit -a -m ?changed images'
git push
```

Open your app on a mobile phone at `http://username.github.io/360gallery`.

## Next steps

This is a brief taste of A-Frame to illustrate that WebVR is easy and
accessible to web developers. Go to [aframe.io](http://aframe.io) to see
more demos. Although the display of 360 images is not true VR, it is
easy, fun, and accessible today. Using 360 images is also a great way
to start to understand the basics of augmented reality.

Take your own pictures with a standard camera and stitch them together
or buy or borrow a 360-degree camera. The camera I used supports
360-degree video files and live streaming.

## Troubleshooting

The application won't run from a local file that you open in your
browser. You must either run a local webserver like Apache2 or upload
it to an external site like GitHub Pages for testing.

If you're using an Oculus Rift or HTC Vive, you may need to install
Firefox Nightly or experimental Chromium builds. See the current
status of your browser at [Is WebVR Ready?](https://iswebvrready.org/)

360-degree video works on desktop browsers. I've experienced some
glitches on mobile devices. The technology is improving quickly.

Source [OpenSource](https://opensource.com/life/16/11/build-virtual-reality-app)


