---
title: Installing Void Linux
tags: backups, boot, configuration, desktop, device, directory, drive, filesystem, installation, linux, login, manager, network, partition, password, power, scripts, security, software, sudo, windows
---

I made the switch to [void linux][void].  Except for compatibility
issues around `glibc`, it works quite well.  Most compatibility
I have worked around with a combination of `Flatpak`s, `chroot`s and
`namespaces`.

The high lights of [void linux][void]:

- musl build - which is very lightweigth
- Does not depend on `systemd`
- a reasonable selection of software packages

I have tweaked the installation on my computers to use UEFI and thus
I am using [rEFInd][refind] instead of grub.  This is because it makes
doing bare metal backups and restore just a simple file copy.

My installation process roughly follows the [UEFI chroot install][void-uefi].

This process is implemented in a script and can be found here:

- [install.sh](https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/install.sh)

Script usage:

```
	Usage: installer.sh _/dev/sdx_ _hostname_ [options]

	- _sdx_: Block device to install to or
	  - --image=filepath[:size] to create a virtual disc image
	  - --imgset=filebase[:size] to create a virtual filesystem image set
	  - --dir=dirpath to create a directory
	- _hostname_: Hostname to use

	Options:
	- swap=kbs : swap size, defaults computed from /proc/meminfo, uses numfmt to parse values
	- glibc : Do a glibc install
	- noxwin : do not insall X11 related packages
	- nodesktop ; do not install desktop environment
	- desktop=mate : Install MATE dekstop environment
	- passwd=password : root password (prompt if not specified)
	- enc-passwd=encrypted : encrypted root password.
	- ovl=tar.gz : tarball containing additional files
	- post=script : run a post install script
	- pkgs=file : text file containing additional software to install
	- bios : create a BIOS boot system (needs syslinux)
	- cache=path : use the file path for download cache
	- xen : do some xen specific tweaks
```

### Command line examples

- sudo sh install.sh --dir=$HOME/vx9 vx9 swap=4G glibc passwd=1234567890 cache=$HOME/void-cache xen
- sudo sh install.sh --dir=$HOME/vx1 vx1 swap=4G glibc passwd=1234567890 cache=$HOME/void-cache xen
- sudo sh install.sh --dir=$HOME/vx11 vx11 swap=4G       passwd=1234567890 cache=$HOME/void-cache xen



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
mkfs.xfs -f -L voidlinux /dev/xda3
```


We're now ready to mount the volumes, making any necessary mount point directories along the way (the sequence is important, yes):

```
mount /dev/xda3 /mnt
mkdir /mnt/boot
mount /dev/xda1 /mnt/boot
```


## Installing Void

So we do a targeted install:

For musl-libc

```
env XBPS_ARCH=x86_64-musl xbps-install -S -R http://alpha.de.repo.voidlinux.org/current/musl -r /mnt base-system grub-x86_64-efi
```

For glibc
```
env XBPS_ARCH=x86_64 xbps-install -S -R http://alpha.de.repo.voidlinux.org/current -r /mnt base-system grub-x86_64-efi
```

But actually, for the package list I have been using these lists:

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/swlist.txt"></script>
<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/swlist-xwin.txt?footer=minimal"></script>
<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/swlist-mate.txt?footer=minimal"></script>

This installs a [MATE][mate] desktop environment.

### Software selection notes

- For time synchronisation (ntp) we ae choosing `chrony` as it is
  reputed to be more secure that `ntpd` and more compliant than
  `openntpd`.
- We are using the default configuration, which should be OK.  Uses
  `pool.ntp.org` for the time server which would use a suitable
  default.
- For `cron` we are using `dcron`.  It is full featured (i.e.
  compatibnle with `cron` and it can handle power-off situations,
  while being the most light-weight option available.
  See: [VoidLinux FAQ: Cron](https://voidlinux.org/faq/#cron)
- Includes `autofs` and `nfs-utils` for network filesystems and
  automount support.

## nonfree software and other repositories

Additional repositories are available to support either
non-free software and in the case of glibc, multilib (32 bit)
binaries.

To enable under the musl version:

```
env XBPS_ARCH="$arch" xbps-install -y -S -R "$voidurl" -r /mnt void-repo-nonfree
```

For glibc:

```
env XBPS_ARCH="$arch" xbps-install -y -S -R "$voidurl" -r /mnt void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
```

Then you can install non-free software, like:

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/swlist-nonfree.txt"></script>


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

Since I am a `bash` convert, I would do this:

```
 xbps-alternatives --set bash
```

Create the `hostname` for the new install:

```
echo <HOSTNAME> > /etc/hostname
```

Edit our `/etc/rc.conf` file, like so:

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

# <file system>	<dir>	<type>	<options>		<dump>	<pass>
tmpfs		/tmp	tmpfs	defaults,nosuid,nodev   0       0
LABEL=EFI	/boot	vfat	rw,fmask=0133,dmask=0022,noatime,discard  0 2
LABEL=voidlinux	/	xfs	rw,relatime,discard	0 1
LABEL=swp0 	swap	swap	defaults		0 0
```

For a removable drive I include the line:

```
LABEL=volume	/media/blahblah xfs	rw,relatime,nofail 0 0
```

The important setting here is **nofail**.  When the drive is
available it gets mounted.  If not, the **nofail** prevents
this to cause the boot sequence to stop.

If using `glibc` you can modify `/etc/default/libc-locales` and
uncomment:

`en_US.UTF-8 UTF-8`

Or whatever locale you want to use.  And run:

```
 xbps-reconfigure -f glibc-locales
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

The version I am using right now can be found here: [v0.11.4 BOOTX64.EFI](https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/BOOTX64.EFI)

Create kernel options files `/boot/cmdline`:

```
root=LABEL=voidlinux ro quiet

```

For my hardware I had to add the option:

- `intel_iommu=igfx_off`
  - To work around some strange bug.
- `i915.enable_ips=0`
  - fixes a power saving mode problem on 4.1-rc6+

Create the following script as `/boot/mkmenu.sh`

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/mkmenu.sh"></script>

Add the following scripts to:

- `/etc/kernel.d/post-install/99-refind`
- `/etc/kernel.d/post-remove/99-refind`

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/hook.sh"></script>

Make sure they are executable.  This is supposed to re-create
menu entries whenever the kernel gets upgraded.

We need to have a look at `/lib/modules` to get our Linux kernel version

```
ls -la /lib/modules
```

Which should return something akin to:

```
drwxr-xr-x  3 root root   21 Jan 31 15:22 .
drwxr-xr-x 23 root root 8192 Jan 31 15:22 ..
drwxr-xr-x  3 root root 4096 Jan 31 15:22 5.2.13_1
```

And this script to create boot files:

```
xbps-reconfigure -f linux5.2
```


If you need to manually prepare boot files:

```
# update dracut
dracut --force --kver 4.19.4_1
# update refind menu
bash /boot/mkmenu.sh
```

We are now ready to boot into [Void][void].

```
exit
umount -R /mnt
reboot
```

## Post install

After the first boot, we need to activate services:

Command line set-up:

```
ln -s /etc/sv/dhcpcd /var/service
ln -s /etc/sv/sshd /var/service
ln -s /etc/sv/{acpid,chronyd,cgmanager,crond,uuidd,statd,rcpbind,autofs} /var/service
```

Full workstation set-up:

```
ln -s /etc/sv/dbus /var/service
ln -s /etc/sv/NetworkManager /var/service
ln -s /etc/sv/sshd /var/service
ln -s /etc/sv/{acpid,chronyd,cgmanager,crond,uuidd,statd,rcpbind,autofs} /var/service
ln -s /etc/sv/{consolekit,xdm} /var/service
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



## Configure keyboard

Create configuration file: `/etc/X11/xorg.conf.d/30-keyboard.conf`

```
Section "InputClass"
    Identifier "keyboard-all"
    Option "XkbLayout" "us"
    # Option "XkbModel" "pc105"
    # Option "XkbVariant" "altgr-intl"
    Option "XkbVariant" "intl"
    # MatchIsKeyboard "on"
EndSection
```

This makes the `intl` for the `XkbVariant` the system-wide default.

Since, as a programmer I prefer the `altgr-intl` variant, then I
run this in my de desktop environment startup to override the
default:

```
setxkbmap -rules evdev -model evdev -layout us -variant altgr-intl

```

## Using xdm

I have switched to [xdm][xdm] as my display manager.  This is
configured in `/etc/X11/xdm/xdm-config`.

Specifically, I update the Xsession setting to be the following:

```
! DisplayManager*session:		/usr/lib64/X11/xdm/Xsession
DisplayManager*session:		/etc/X11/Xsession

```

And have a custom [Xsession](https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/xdm/Xsession) script in
`/etc/X11/Xsession`.

Particularly important is the fact that the default Xsession
script is not able to start a `mate` or `xfce4` sessions
until you add the command:

```
xhost +local:

```

Apparently there is somewhat of an issue in the way `xauth`
is handled.

**NOTE:** _Doing `xhost +local:` is hardly a best practice
when it comes to security._

### Spicing up XDM

Allthough [xdm][xdm] is fairly old-school, there are
still some opportunities to add some eye-candy to
it.  For that, we change the `setup` and `startup` scripts
`Xsetup_0` and `GiveConsole` into custom scripts:

- [Xsetup_0](https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/xdm/Xsetup_0)
- [GiveConsole](https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/xdm/GiveConsole)

Unfortunately, it only works for applications that draw
directly to the root window as it is not possible to control
overlapping windows.  For example, running `cmatrix` on
a `xterm` window covers the login widget.

On the other hand, the [xscreensaver][xs] collection of screen
hacks seem to accept the `-root` parameter, which can be used
to kick off the hack, drawing on the root window.


## Tweaks and Bug-fixes

### /etc/machine-id or /var/lib/dbus/machine-id

Because we don't use `systemd`, we need to create `/etc/machine-id`
and `/var/lib/dbus/machine-id`.
manually.  This is only needed for desktop systems.

See [this article][machineid] for more
info.

```
  dbus-uuidgen | tee /etc/machine-id /var/lib/dbus/machine-id
```

### power button handling

This patch prevents the /etc/acpi/handler.sh to handle the power button
instead, letting the Desktop Environment handle the event.

It does it by checking if the Desktop Environment power manager
(in this case `mate-power-manager`) is running.  If it is, then
it will exit.

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/acpi-handler.patch"></script>

### rtkit spamming logs

Apparently, `rtkit` requres an `rtkit` user to exist.  Otherwise it
will spam the logs with error messages.  To correct use this command:

```
useradd -r -s /sbin/nologin rtkit
```

### xen tweaks

For xen we need to make some adjustments...

1. Tweak block device references.
   - `/etc/fstab` : mount xvda and other devices
   - `/boot/cmdline` : get the right xvda root device
2. Enable disable services
   - Disable: `slim`, `agetty-ttyX`
   - Enable: `agetty-hvc0`
   - Decide if you want to use `NetworkManager` or `dhcpcd`.

Normally, I would create a tarball image to transfer over, in order
for the image to work properly you need to save `capabilities`.


## Old Notes

### PolKit rule tweaks

Testing as of 2019-09-07, the following does not seem to be needed
any longer.  I left it here just for reference (in case it breaks
again.

* * *

OK, in my case, `shutdown`, `reboot` and local media access functions
were not available using the [MATE][mate] desktop.

To enable this I had to create/tweak the PolKit rules...

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/_attic_/tweak-polkit-rules.sh"></script>

## Using SLIM

I have switched to [SLiM][SLiM] as the display manager.  This is
configured in `/etc/slim.conf`.

Specifically, I update the login_cmd to be the following:

```
login_cmd exec /bin/sh -l /etc/X11/Xsession %session
```


