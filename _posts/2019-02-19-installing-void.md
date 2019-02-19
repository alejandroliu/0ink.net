---
title: Installing Void Linux
---

# Void Linux installation

I am making a switch to [void linux][void].  So far it has been working
fine.  I like that it is very stream-lined and hardware support
has been mostly fine.

I have tweaked the installation on my computers to use UEFI and thus 
I am using [rEFInd][refind] instead of grub.  This is because it makes
doing bare metal backups and restore just a simple file copy.  Using
UEFI grub or my previous BIOS based boot process would require doing some
EFI tricks or installing MBR and the like.  Right now, I just need
to partition things right and copy things to the right location to
have a working system.

My installation process roughly follows the [UEFI chroot install][void-uefi].

## Initial set-up

Boot using the void live CD and partition the target disk:

```
cfdisk -z /dev/xda
```

Make sure you use `gpt` label type (for UEFI boot).  I am creating
the following partitions:

1. 500MB `EFI System`
2. *RAM Size * 1.5* `Linux swap`, Mainly used for Hibernate.
3. *Rest of drive* `Linux filesystem`, Root file system

This is on a USB thumb drive.  The data I keep on an internal disk.

Now we create the filesystems:

```
mkfs.vfat -F 32 -n EFI /dev/xda1
mkswap -L swp0 /dev/xda2
mkfs.xfs -L voidlinux /dev/xda3
```

We're now ready to mount the volumes, making any necessary mount point directories along the way (the sequence is important, yes): 


```
mount /dev/xda3 /mnt
mkdir /mnt/boot
mount /dev/xda1 /mnt/boot
```

## Installing Void

So we do a targetted install:

For musl-libc

```
env XBPS_ARCH=x86_64-musl xbps-install -S -R http://alpha.de.repo.voidlinux.org/current/musl -r /mnt base-system grub-x86_64-efi
```

For glibc (untested)
```
env XBPS_ARCH=x86_64 xbps-install -S -R http://alpha.de.repo.voidlinux.org/current/musl -r /mnt base-system grub-x86_64-efi
```

But actually, for the package list I have been using this list:

```
alsa-plugins-pulseaudio
base-system
cryptsetup
dejavu-fonts-ttf
dialog
firefox-esr
font-misc-misc
gnome-keyring
grub-i386-efi
grub-x86_64-efi
gvfs-afc
gvfs-mtp
gvfs-smb
intel-ucode
lvm2
lxdm
mate
mate-extra
mdadm
network-manager-applet
setxkbmap
terminus-font
udisks2
xauth
xorg-input-drivers
xorg-minimal
xorg-video-drivers
zip
unzip
wget
```

This installs a [MATE][mate] desktop environment.

## Enter the void chroot

Upon completion of the install, we set up our chroot jail, and chroot into our mounted filesystem:

```
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o bind /dev /mnt/dev
mount -t devpts pts /mnt/dev/pts
cp -L /etc/resolv.conf /mnt/etc/
chroot /mnt bash -il
```

In order to verify our install, we can have a look at the directory structure:

```
ls -la
```

The output should look something akin to the following:

```
total 12
drwxr-xr-x 16 root root 4096 Jan 17 15:27 .
drwxr-xr-x  3 root root 4096 Jan 17 15:16 ..
lrwxrwxrwx  1 root root    7 Jan 17 15:26 bin -> usr/bin
drwxr-xr-x  4 root root  127 Jan 17 15:37 boot
drwxr-xr-x  2 root root   17 Jan 17 15:26 dev
drwxr-xr-x 26 root root 4096 Jan 17 15:27 etc
drwxr-xr-x  2 root root    6 Jan 17 15:26 home
lrwxrwxrwx  1 root root    7 Jan 17 15:26 lib -> usr/lib
lrwxrwxrwx  1 root root    9 Jan 17 15:26 lib32 -> usr/lib32
lrwxrwxrwx  1 root root    7 Jan 17 15:26 lib64 -> usr/lib
drwxr-xr-x  2 root root    6 Jan 17 15:26 media
drwxr-xr-x  2 root root    6 Jan 17 15:26 mnt
drwxr-xr-x  2 root root    6 Jan 17 15:26 opt
drwxr-xr-x  2 root root    6 Jan 17 15:26 proc
drwxr-x---  2 root root   26 Jan 17 15:39 root
drwxr-xr-x  3 root root   17 Jan 17 15:26 run
lrwxrwxrwx  1 root root    8 Jan 17 15:26 sbin -> usr/sbin
drwxr-xr-x  2 root root    6 Jan 17 15:26 sys
drwxrwxrwt  2 root root    6 Jan 17 15:15 tmp
drwxr-xr-x 11 root root  123 Jan 17 15:26 usr
drwxr-xr-x 11 root root  150 Jan 17 15:26 var
```

While chrooted, we create the password for the root user, and set root access permissions:

```
passwd root
chown root:root /
chmod 755 /
```

Create the `hostname` for the new install:

```
echo <HOSTNAME> > /etc/hostname
```

Edit our `rc.conf` file, like so:

```
HOSTNAME="<HOSTNAME>"

# Set RTC to UTC or localtime.
HARDWARECLOCK="UTC"

# Set timezone, availables timezones at /usr/share/zoneinfo.
TIMEZONE="Europe/Amsterdam"

# Keymap to load, see loadkeys(8).
KEYMAP="us-acentos"

# Console font to load, see setfont(8).
#FONT="lat9w-16"

# Console map to load, see setfont(8).
#FONT_MAP=

# Font unimap to load, see setfont(8).
#FONT_UNIMAP=

# Kernel modules to load, delimited by blanks.
#MODULES=""
```

Also, modify the `/etc/fstab`:

```
#
# See fstab(5).
#
# <file system>	<dir>	<type>	<options>		<dump>	<pass>
tmpfs		/tmp	tmpfs	defaults,nosuid,nodev   0       0
LABEL=EFI	/boot	vfat	rw,fmask=0133,dmask=0022,noatime,discard	
0	2
LABEL=voidlinux	/	xfs	rw,relatime,discard	0 1
LABEL=swp0 	swap	swap	defaults		0 0
```

For a removable drive I include the line:

```
LABEL=volume	/media/blahblah xfs	rw,relatime,nofail 0 0
```

The important setting here is **nofail**.

If using `glibc` you can modify `/etc/default/libc-locales` and
uncomment:

`en_US.UTF-8 UTF-8`

Or whatever locale you want to use.  And run:

```
xbps-reconfigure -f glibc-locales
```

We need to have a look at `/lib/modules` to get our Linux kernel version

```
ls -la /lib/modules
```

Which should return something akin to:

```
drwxr-xr-x  3 root root   21 Jan 31 15:22 .
drwxr-xr-x 23 root root 8192 Jan 31 15:22 ..
drwxr-xr-x  3 root root 4096 Jan 31 15:22 4.0.4_1
```

Update dracut:

```
# dracut --force --kver 4.0.4_1
```

## Set-up UEFI boot

Download the [rEFInd][refind] zip binary from:

* [rEFInd download][getting-refind]

Set-up the boot partition:

```
mkdir /boot/EFI
mkdir /boot/EFI/BOOT
```

Copy from the `zip file` the file `refind-bin-{version}/refind/refind_x64.efi` to
`/boot/EFI/BOOT/BOOTX64.EFI`.

Create kernel options files `/boot/cmdline`:

```
root=LABEL=voidlinux ro quiet

```

For my hardware I had to add the option:

- `intel_iommu=igfx_off`
  To work around some strange bug.

Create the following script as `/boot/mkmenu.sh`

```
#!/bin/bash
set -euf -o pipefail

die() {
  echo FATAL:"$@" 1>&2
  exit "$1"
}
  

bootdir=$(cd $(dirname $0) && pwd)
[ -z "$bootdir" ] &&  die 1 "Missing bootdir"

if [ -f "$bootdir/cmdline" ] ; then
  def_cmdline="$(cat $bootdir/cmdline)"
else
  def_cmdline="auto"
fi

find_kernels() {
  find "$bootdir" -maxdepth 1 -type f -name 'vmlinuz*' | (while read k
  do
    kver=$(basename "$k" | cut -d- -f2-)
    [ -f "$bootdir/initramfs-$kver.img" ] || continue
    echo "$kver"
  done) | sort -r
}

find_kernels

(
  echo "scanfor manual"
  echo "timeout 3"
  echo "default_selection 1"

  for kver in $(find_kernels)
  do
    echo "menuentry \"linux-$kver\" {"
    echo "  loader /vmlinuz-$kver"
    echo "  initrd /initramfs-$kver.img"
    if [ -f "$bootdir/cmdline-$kver" ] ; then
      echo "  options" \"$(cat "$bootdir/cmdline-$kver")\"
    else
      echo "  options" \"$def_cmdline\"
    fi
    echo "}"
  done
) > "$bootdir/EFI/BOOT/refind.conf"
```

And run this script to create the boot menu entries:

```
xbps-reconfigure -f linux4.0
bash /boot/mkmenu.sh
```

FIXME: should add a something in `/etc/kernel.d` so that this is
call automatically on a kernel upgrade.

We are now ready to boot into [Void][void].

```
exit
umount -R /mnt
reboot
```

## Post install

After the first boot, we need to activate services:

```
ln -s /etc/sv/{NetworkManager,acpid,cgmanager,consolekit,dbus,dhcpcd,lxdm,polkitd,rtkit,sshd,uuidd} /var/service
```

Since I am a `bash` convert, I would do this:

```
xbps-alternatives --set bash
```

Creating new users:

```
useradd -m -s /bin/bash -U -G wheel,users,audio,video,cdrom,input newuser
passwd newuser
```

Note: The `wheel` user group allows the user to escalate to root.

Configure sudo:

```
visudo
```

Uncomment:

```
# %wheel ALL=(ALL) ALL
```

## Tweaks

OK, in my case, shutting down and rebooting was not activated in
the [MATE][mate] desktop menu.  To enable this I had to create
a file `/etc/polkit-1/rules.d/void-live.rules`:

```
polkit.addAdminRule(function(action, subject) {
    return ["unix-group:wheel"];
});

polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
```

FIXME: I think this may be a bug, or maybe I need to install: `polkit-gnome`.
The documentation states it should just work.

I like to be able to hibernate when somebody push the power button.
For that you need to patch `/etc/acpi/handler.sh` as follows:

```
--- handler.sh	2019-02-19 06:34:44.007629342 +0100
+++ handler-hib.sh	2019-02-19 06:35:08.130628479 +0100
@@ -26,8 +26,14 @@
         #echo "PowerButton pressed!">/dev/tty5
         case "$2" in
             PBTN|PWRF)
-		    logger "PowerButton pressed: $2, shutting down..."
-		    shutdown -P now
+		    is_active=$(ck-list-sessions | grep active | grep TRUE | wc -l)
+		    if [ $is_active -gt 0 ] ; then
+		      logger "PowerButton pressed: $2, Hibernating..."
+		      ZZZ
+		    else
+		      logger "PowerButton pressed: $2, Shutting down..."
+		      shutdown -P now
+                    fi
 		    ;;
             *)      logger "ACPI action undefined: $2" ;;
         esac
```
FIXME: Use "chvt 5" and show text explaining what we are doing
in /dev/tty5

Additional software:

```
geany
geany-plugins
geany-plugins-extra
git
tcl
tk
mplayer
ffmpeg
gst-libav
```
Check [here](https://www.youtube.com/html5) to make sure FireFox
can play `mp4` files.


 [void]: https://voidlinux.org "Void Linux"
 [refind]: http://www.rodsbooks.com/refind/ "rEFInd bootloader"
 [void-uefi]: https://wiki.voidlinux.org/Installation_on_UEFI,_via_chroot "Install void linux on UEFI via chroot"
 [mate]: https://mate-desktop.org/ "MATE Desktop environment"
 [getting-refind]: http://www.rodsbooks.com/refind/getting.html "rEFInd download page"

