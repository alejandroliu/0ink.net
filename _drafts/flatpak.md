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
