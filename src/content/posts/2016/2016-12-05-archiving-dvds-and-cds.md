---
ID: "1012"
post_author: "2"
post_date: "2016-12-05 21:27:58"
post_date_gmt: "2016-12-05 21:27:58"
post_title: Archiving DVDs and CDs
post_excerpt: ""
post_status: publish
comment_status: open
ping_status: open
post_password: ""
post_name: archiving-dvds-and-cds
to_ping: ""
pinged: ""
post_modified: "2016-12-05 21:29:53"
post_modified_gmt: "2016-12-05 21:29:53"
post_content_filtered: ""
post_parent: "0"
guid: https://0ink.net/?p=1012
menu_order: "0"
post_type: post
post_mime_type: ""
comment_count: "0"
title: Archiving DVDs and CDs
tags: android, information, library, scripts, tools
---


Since now I have a Android TV I put away my HTPC and with that the capability to view DVDs or
listen CDs directly.

So I converted my entire CD and DVD library to media files and stored in my home NAS.

Since we are talking hundreds of DVDs and CDs, I was using some tools.

# CD ripping

For CD ripping, pretty much everything can be done with [abcde](https://abcde.einval.com/wiki/).
I would use the following command:

    abcde -G -k -o mp3 -x

Options:

* `-G` : Get album art.
* `-k` : Keep `wav` after encoding.  This is not really necessary.
* `-o mp3` : Output to `mp3`.
* `-x` : Eject the CD after all tracks have been read.

Afterwards I would use [eyeD3](http://eyed3.nicfit.net/) to embed the
cover art and tweak things.  (Note under [archlinux](http://archlinux.org),
`eyeD3` is installed from the `python2-eyed3` package).

### To add cover art:

    eyeD3 --add-image="$cover_file":FRONT_COVER \*.mp3

# DVD Ripping

For DVD Ripping I was using a couple of homegrown scripts.  These can be found on
[github](https://github.com/alejandroliu/MediaArchiving).

I started using [vobcopy](http://vobcopy.org/download/release_notes_and_download.shtml),
but if I were to do this again I would use [dvdbackup](http://dvdbackup.sourceforge.net/)
with the `-M` option.  `vobcopy` is quite old and probably is orphaned by now.

## Scripts for archiving media

Scripts:

- archive-dvd : Create an iso image from a DVD.
- alltitles : Extract titles/chapters from a DVD.
- auto.sh : Used to transcode titles/chapters extracted by `alltitles`

### archive-dvd

This script uses `vobcopy` and `mkisofs` to create an ISO file.
Just run the script and insert a DVD, you will get an ISO file
in return.

### alltitles

Usage:

    [option_vars] sh alltitles [chapter]

Option vars:

- drive=[device-path] defaults to /dev/sr0
- titles="01 02 03 ..." defaults to all titles in DVD (as listed by
  lsdvd)
  You can also specify titles as:
  `title="01,1-4 01,5-8"`
  This will create two files, one with track 1, chaptes one trough
  four (inclusive)
  and another one with track 1, chapters five through eigth (inclusive)

Command options:

chapter: Leave blank for all chapters, otherwise:

    -chapter [$start-$end]

Will dump starting from $start until $end. (or end)
If you only want to extract chapter 7 by itself, use -chapter 7-7

### auto.sh

Usage:

    sh $0 [options]

vob files must be the ones extracted from `alltitles`.

Options:

* --preview|-p : Only encode 30 seconds from 4 minutes in
* --copy|-c : Do only copy
* --interlace|-i : Force interlace filter
* --no-interlace|+i : Disables interlace filter

## Dependancies


- libdvdcss (or equivalent).
  This is used by the dvdread library to decode CSS protected DVDs.
- libdvdread
  This is used to read DVD by a number of binaries.
- [vobcopy](http://vobcopy.org/download/release_notes_and_download.shtml)
  Used by `archive-dvd` to extract the data that will be used to create
  the ISO image.  Uses `libdvdread`.
- udisks or udisks2
  Used by the scripts to detect when a CD/DVD is inserted.
- cdrkit
  Used to create the iso images by `archive-dvd`.
- lsdvd
  Used by `alltitles.sh` to get track information.
- mplayer
  Used by `alltitles.sh` to extract DVD titles/chapters.
- ffmpeg
  Used by `alltitles.sh` to encode video.

## Some useful commands

Using `mplayer` to play extract:

    mplayer -dvd-device /dev/sr0 dvd://$title -chapter $chapter-$chapter -dumpstream -dumpfile ~/$title.VOB


