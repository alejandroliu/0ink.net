---
title: flatpak
date: 1111-11-11
---

Install Flatpak

To install Flatpak, run the following:




 sudo xbps-install -S flatpak


Add the Flathub repository

Flathub is the best place to get Flatpak apps. To enable it, run:




 flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo


Restart

To complete setup, restart your system. Now all you have to do is install some apps!

- com.dropbox.Client: Dropbox - Access your files from any computer
- org.gnome.Platform: GNOME Application Platform version 3.28 - Shared libraries used by GNOME applications

Not sure:
- org.freedesktop.Platform.VAAPI.Intel: Intel VAAPI Driver - Intel driver for hardware accelerated video decoding and playback
- org.freedesktop.Platform.ffmpeg: FFmpeg extension - Add support for aac, mpeg4 and h264
Calibre	com.calibre_ebook.calibre	4.10.1	stable	system
Spotify	com.spotify.Client	1.1.55.498.gf9a83c60	stable	system
Freedesktop Platform	org.freedesktop.Platform	19.08.14	19.08	system
Freedesktop Platform	org.freedesktop.Platform	20.08.13	20.08	system
default	org.freedesktop.Platform.GL.default		19.08	system
Mesa	org.freedesktop.Platform.GL.default	21.1.1	20.08	system
Intel	org.freedesktop.Platform.VAAPI.Intel		19.08	system
Intel	org.freedesktop.Platform.VAAPI.Intel		20.08	system
openh264	org.freedesktop.Platform.openh264	2.1.0	2.0	system
Firefox	org.mozilla.firefox	89.0	stable	system
