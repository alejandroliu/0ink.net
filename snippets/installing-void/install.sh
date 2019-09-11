#!/bin/bash
#
set -euf -o pipefail
script=$(readlink -f "$0")

repourl=https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void

if [ $# -eq 0 ] ; then
  # Show documentation...
  sed -e 's/^/:/' "$script" | (
    output=":"
    while read ln
    do
      if [ x"$ln" = x":#begin-output" ] ; then
	output="echo"
      elif [ x"$ln" = x":#end-output" ] ; then
	output=":"
      else
	$output "$ln"
      fi
    done
  ) | sed \
	-e 's/^:## //' \
	-e 's/^:##//' \
	-e 's/^://' \
    | sed \
	-e 's!$repourl!'"$repourl!" \
	-e 's!$0!installer.sh!'
  exit 0
fi

check_opt() {
  local flag="$1" ; shift
  for j in "$@"
  do
    if [ x"${j%=*}" = x"$flag" ] ; then
      echo "${j#*=}"
      return 0
    fi
  done
  return 1
}
die() {
  echo ERROR: "$@" 1>&2
  exit $1
}
is_valid_desktop() {
  case "$1" in
    mate) return 0 ;;
  esac
  return 1
}

#begin-output
## ---
## title: Installing Void Linux
## ---
##
## I am making a switch to [void linux][void].  So far it has been working
## fine.  I like that it is very stream-lined and hardware support
## has been mostly fine.
##
## I have tweaked the installation on my computers to use UEFI and thus 
## I am using [rEFInd][refind] instead of grub.  This is because it makes
## doing bare metal backups and restore just a simple file copy.  Using
## UEFI grub or my previous BIOS based boot process would require doing some
## EFI tricks or installing MBR and the like.  Right now, I just need
## to partition things right and copy things to the right location to
## have a working system.
##
## My installation process roughly follows the [UEFI chroot install][void-uefi].
##
## This process is implemented in a script and can be found here:
##
## - [install.sh]($repourl/install.sh)
##
## Script usage:
##
## ```
#end-output
if [ $# -lt 2 ] ; then
  cat <<-_EOF_
#begin-output
	Usage: $0 _sdx_ _hostname_ [options]
	
	- _sdx_: Block device to install to
	- _hostname_: Hostname to use

	Options:
	- mem=memory : memory size, defaults computed from /proc/meminfo
	- glibc : Do a glibc install
	- noxwin : do not insall X11 related packages
	  desktop=no ; do not install desktop environment
	  desktop=mate : Install MATE dekstop environment
#end-output
	_EOF_
  exit 1
fi
sysdev="$1"
syshost="$2"
shift 2

if [ -d "$sysdev" ] ; then
  echo "$sysdev: is a directory"
  [ $(readlink -f "$sysdev") = "/mnt" ] && die 5 "Can not use /mnt"
elif [ -b "$sysdev" ] ; then
  echo "$sysdev: is a block device"
  mounts=$(mount | grep '^'"$sysdev"| wc -l) || :
  if [ $mounts -gt 0 ] ; then
    echo "$sysdev: is in use!"
    exit 1
  fi
else
  echo "$sysdev: does not exist!"
fi

#begin-output
## ```
##
## ## Initial set-up
##
## Boot using the void live CD and partition the target disk:
##
## ```
## cfdisk -z /dev/xda
## ```
##
## Make sure you use `gpt` label type (for UEFI boot).  I am creating
## the following partitions:
##
## 1. 500MB `EFI System`
## 2. *RAM Size * 1.5* `Linux swap`, Mainly used for Hibernate.
## 3. *Rest of drive* `Linux filesystem`, Root file system
#end-output

mem=$(check_opt mem "$@") || :
if [ -n "$mem" ] ; then
  mem=$(numfmt --from-iec --to-unit=1024 "$mem")
  [ -z "$mem" ] && die 1 "Invalid number for mem"
else
  mem=$(awk '$1 == "MemTotal:" { print $2 }' /proc/meminfo)
fi


# Partition block device...
if [ -b "$sysdev" ] ; then
  csize=$(expr $(blockdev --getsz "$sysdev") / 2) # Size of block device in K's
  swapsz=$(expr $mem + $(expr $mem / 2))
  uefisz=$(numfmt --to-unit=1024 --from=iec 500M)
  rootsz=$(numfmt --to-unit=1024 --from=iec 4G)
  req=$(expr $uefisz + $swapsz + $rootsz)
  
  #~ echo csize=$(numfmt --to=iec --from=iec ${csize}K)
  #~ echo req=$(numfmt --to=iec --from=iec ${req}K)

  [ $req -gt $csize ] && die 2 "$sysdev is too small ($(numfmt --to=iec --from=iec ${csize}K) < $(numfmt --to=iec --from=iec ${req}K))" || :
  sfdisk "$sysdev" <<-_EOF_
	label: gpt

	,${uefisz}K,U,*
	,${swapsz}K,S,
	,,L,
	_EOF_

fi

#begin-output
##
## This is on a USB thumb drive.  The data I keep on an internal disk.
##
## Now we create the filesystems:
##
## ```
## sysdev=<block device>
##
#end-output
if [ -b "$sysdev" ] ; then
#begin-output
mkfs.vfat -F 32 -n EFI "${sysdev}1"
mkswap -L swp0 "${sysdev}2"
mkfs.xfs -f -L voidlinux "${sysdev}3"
#end-output
fi
#begin-output
## ```
##
## We're now ready to mount the volumes, making any necessary mount point directories along the way (the sequence is important, yes): 
##
## ```
#end-output
if [ -b "$sysdev" ] ; then
#begin-output
mount "${sysdev}3" /mnt
mkdir /mnt/boot
mount "${sysdev}1" /mnt/boot
#end-output
elif [ -d "$sysdev" ] ; then
  mount --rbind "$sysdev" "/mnt"
fi
#begin-output
## ```
##
## ## Installing Void
##
## So we do a targetted install:
##
## For musl-libc
##
## ```
## env XBPS_ARCH=x86_64-musl xbps-install -S -R http://alpha.de.repo.voidlinux.org/current/musl -r /mnt base-system grub-x86_64-efi
## ```
##
## For glibc (untested)
## ```
## env XBPS_ARCH=x86_64 xbps-install -S -R http://alpha.de.repo.voidlinux.org/current -r /mnt base-system grub-x86_64-efi
## ```
##
## But actually, for the package list I have been using these lists:
##
## <script src="https://gist-it.appspot.com/$repourl/swlist.txt?footer=minimal"></script>
## <script src="https://gist-it.appspot.com/$repourl/swlist-xwin.txt?footer=minimal"></script>
## <script src="https://gist-it.appspot.com/$repourl/swlist-mate.txt?footer=minimal"></script>
##
## This installs a [MATE][mate] desktop environment.
##
#end-output
if ! check_opt glibc "$@" ; then
  # MUSL installation
  arch="x86_64-musl"
  repourl="http://alpha.de.repo.voidlinux.org/current/musl"
else
  # GLIBC installation
  arch="x86_64"
  repourl="http://alpha.de.repo.voidlinux.org/current"
fi
desktop=$(check_opt desktop "$@") || :
[ -z "$desktop" ] && desktop=mate

env XBPS_ARCH="$arch" xbps-install -S -R "$repourl" -r /mnt $(
  set -x
  (wget -O- "$repourl/swlist.txt" 
  if ! check_opt noxwin "$@" ; then
    wget -O- "$repourl/swlist-xwin.txt"
    if is_valid_desktop "$desktop" ; then
      wget -O- "$repourl/swlist-$desktop.txt" | sed -e 's/#.*$//'
    fi
  fi
  )| sed -e 's/#.*$//'
)
#begin-output
## ### Software selection notes
##
## - For time synchronisation (ntp) we ae choosing `chrony` as it is
##  reputed to be more secure that `ntpd` and more compliant than
##  `openntpd`.
## - We are using the default configuration, which should be OK.  Uses
##  `pool.ntp.org` for the time server which would use a suitable
##   default.
## - For `cron` we are using `dcron`.  It is full featured (i.e.
##   compatibnle with `cron` and it can handle power-off situations,
##   while being the most light-weight option available.
##   See: [VoidLinux FAQ: Cron](https://voidlinux.org/faq/#cron)
## - Includes `autofs` and `nfs-utils` for network filesystems and
##   automount support.
##
## ## nonfree software
##
## Install:
##
## ```
## intel-ucode
## unrar
## ```
#end-output
env XBPS_ARCH="$arch" xbps-install -S -R "$repourl" -r /mnt intel-ucode unrar
#begin-output
##
## ## Enter the void chroot
##
## Upon completion of the install, we set up our chroot jail, and chroot into our mounted filesystem:
##
## ```
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o bind /dev /mnt/dev
mount -t devpts pts /mnt/dev/pts
cp -L /etc/resolv.conf /mnt/etc/
## chroot /mnt bash -il
## ```
##
## In order to verify our install, we can have a look at the directory structure:
##
## ```
## ls -la
## ```
##
## The output should look something akin to the following:
##
## ```
## total 12
## drwxr-xr-x 16 root root 4096 Jan 17 15:27 .
## drwxr-xr-x  3 root root 4096 Jan 17 15:16 ..
## lrwxrwxrwx  1 root root    7 Jan 17 15:26 bin -> usr/bin
## drwxr-xr-x  4 root root  127 Jan 17 15:37 boot
## drwxr-xr-x  2 root root   17 Jan 17 15:26 dev
## drwxr-xr-x 26 root root 4096 Jan 17 15:27 etc
## drwxr-xr-x  2 root root    6 Jan 17 15:26 home
## lrwxrwxrwx  1 root root    7 Jan 17 15:26 lib -> usr/lib
## lrwxrwxrwx  1 root root    9 Jan 17 15:26 lib32 -> usr/lib32
## lrwxrwxrwx  1 root root    7 Jan 17 15:26 lib64 -> usr/lib
## drwxr-xr-x  2 root root    6 Jan 17 15:26 media
## drwxr-xr-x  2 root root    6 Jan 17 15:26 mnt
## drwxr-xr-x  2 root root    6 Jan 17 15:26 opt
## drwxr-xr-x  2 root root    6 Jan 17 15:26 proc
## drwxr-x---  2 root root   26 Jan 17 15:39 root
## drwxr-xr-x  3 root root   17 Jan 17 15:26 run
## lrwxrwxrwx  1 root root    8 Jan 17 15:26 sbin -> usr/sbin
## drwxr-xr-x  2 root root    6 Jan 17 15:26 sys
## drwxrwxrwt  2 root root    6 Jan 17 15:15 tmp
## drwxr-xr-x 11 root root  123 Jan 17 15:26 usr
## drwxr-xr-x 11 root root  150 Jan 17 15:26 var
## ```
##
## While chrooted, we create the password for the root user, and set root access permissions:
##
## ```
## passwd root
## chown root:root /
## chmod 755 /
## ```
##
## Since I am a `bash` convert, I would do this:
##
## ```
## xbps-alternatives --set bash
## ```
##
## Create the `hostname` for the new install:
##
## ```
## echo <HOSTNAME> > /etc/hostname
## ```
##
## Edit our `rc.conf` file, like so:
##
## ```
## HOSTNAME="<HOSTNAME>"
##
## # Set RTC to UTC or localtime.
## HARDWARECLOCK="UTC"
##
## # Set timezone, availables timezones at /usr/share/zoneinfo.
## TIMEZONE="Europe/Amsterdam"
## 
## # Keymap to load, see loadkeys(8).
## KEYMAP="us-acentos"
## 
## # Console font to load, see setfont(8).
## #FONT="lat9w-16"
##
## # Console map to load, see setfont(8).
## #FONT_MAP=
##
## # Font unimap to load, see setfont(8).
## #FONT_UNIMAP=
## 
## # Kernel modules to load, delimited by blanks.
## #MODULES=""
## ```
##
## Also, modify the `/etc/fstab`:
##
## ```
## #
## # See fstab(5).
## #
## # <file system>	<dir>	<type>	<options>		<dump>	<pass>
## tmpfs		/tmp	tmpfs	defaults,nosuid,nodev   0       0
## LABEL=EFI	/boot	vfat	rw,fmask=0133,dmask=0022,noatime,discard  0 2
## LABEL=voidlinux	/	xfs	rw,relatime,discard	0 1
## LABEL=swp0 	swap	swap	defaults		0 0
## ```
## 
## For a removable drive I include the line:
## 
## ```
## LABEL=volume	/media/blahblah xfs	rw,relatime,nofail 0 0
## ```
## 
## The important setting here is **nofail**.
## 
## If using `glibc` you can modify `/etc/default/libc-locales` and
## uncomment:
## 
## `en_US.UTF-8 UTF-8`
## 
## Or whatever locale you want to use.  And run:
## 
## ```
## xbps-reconfigure -f glibc-locales
## ```
## 
## ## Set-up UEFI boot
## 
## Download the [rEFInd][refind] zip binary from:
## 
## * [rEFInd download][getting-refind]
## 
## Set-up the boot partition:
## 
## ```
## mkdir /boot/EFI
## mkdir /boot/EFI/BOOT
## ```
## 
## Copy from the `zip file` the file `refind-bin-{version}/refind/refind_x64.efi` to
## `/boot/EFI/BOOT/BOOTX64.EFI`.
## 
## The version I am using right now can be found here: [v0.11.4 BOOTX64.EFI](https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/BOOTX64.EFI)
## 
## Create kernel options files `/boot/cmdline`:
## 
## ```
## root=LABEL=voidlinux ro quiet
## 
## ```
## 
## For my hardware I had to add the option:
## 
## - `intel_iommu=igfx_off`
##   - To work around some strange bug.
## - `i915.enable_ips=0`
##   - fixes a power saving mode problem on 4.1-rc6+
## 
## Create the following script as `/boot/mkmenu.sh`
## 
## <script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/mkmenu.sh?footer=minimal"></script>
## 
## Add the following scripts to: 
## 
## - `/etc/kernel.d/post-install/99-refind`
## - `/etc/kernel.d/post-remove/99-refind`
## 
## <script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/hook.sh?footer=minimal"></script>
## 
## ```
## wget -O- https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/hook.sh | tee /etc/kernel.d/post-{install,remove}/99-refind
## chmod 755 /etc/kernel.d/post-{install,remove}/99-refind
## ```
## 
## Make sure they are executable.  This is supposed to re-create
## menu entries whenever the kernel gets upgraded.
## 
## We need to have a look at `/lib/modules` to get our Linux kernel version
## 
## ```
## ls -la /lib/modules
## ```
## 
## Which should return something akin to:
## 
## ```
## drwxr-xr-x  3 root root   21 Jan 31 15:22 .
## drwxr-xr-x 23 root root 8192 Jan 31 15:22 ..
## drwxr-xr-x  3 root root 4096 Jan 31 15:22 4.19.4_1
## ```
## 
## And this script to create boot files:
## 
## ```
## xbps-reconfigure -f linux4.19
## ```
## 
## If you need to manually prepare boot files:
## 
## ```
## # update dracut
## dracut --force --kver 4.19.4_1
## # update refind menu
## bash /boot/mkmenu.sh
## ```
## 
## We are now ready to boot into [Void][void].
## 
## ```
## exit
umount -R /mnt
## reboot
## ```
## 
## ## Post install
## 
## After the first boot, we need to activate services:
## 
## Command line set-up:
## 
## ```
## ln -s /etc/sv/dhcpcd /var/service
## ln -s /etc/sv/sshd /var/service
## ln -s /etc/sv/{acpid,chronyd,cgmanager,crond,uuidd,statd,rcpbind,autofs} /var/service
## ```
## 
## Full workstation set-up:
## 
## ```
## ln -s /etc/sv/dbus /var/service
## ln -s /etc/sv/NetworkManager /var/service
## ln -s /etc/sv/sshd /var/service
## ln -s /etc/sv/{acpid,chronyd,cgmanager,crond,uuidd,statd,rcpbind,autofs} /var/service
## ln -s /etc/sv/{consolekit,lxdm,polkitd,rtkit} /var/service
## ```
## 
## Creating new users:
## 
## ```
## useradd -m -s /bin/bash -U -G wheel,users,audio,video,cdrom,input newuser
## passwd newuser
## ```
## 
## Note: The `wheel` user group allows the user to escalate to root.
## 
## Configure sudo:
## 
## ```
## visudo
## ```
## 
## Uncomment:
## 
## ```
## # %wheel ALL=(ALL) ALL
## ```
## 
## 
## ## Logging
## 
## 
## Source: [Logging](https://voidlinux.org/faq/#Logging)
## 
## Commands:
## 
## <script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/setup-socklog.sh?footer=minimal"></script>
## 
## ## Tweaks and Bug-fixes
## 
## ### power button handling
## 
## This patch prevents the /etc/acpi/handler.sh to handle the power button
## instead, letting the Desktop Environment handle the event.
## 
## <script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/acpi-handler.patch?footer=minimal"></script>
## 
## ```
## wget -O- https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/acpi-handler.patch | patch -b -z -void -d /etc/acpi
## # or
## wget -O- https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/acpi-handler.patch | sudo patch -b -z -void -d /etc/acpi
## ```
## 
## ### `rtkit` spamming logs
## 
## Apparently, `rtkit` requres an `rtkit` user to exist.  Otherwise it
## will spam the logs with error messages.  To correct use this command:
## 
## ```
## useradd -r -s /sbin/nologin rtkit
## ```
## 
## ## Old Notes
## 
## ### PolKit rule tweaks
## 
## Testing as of 2019-09-07, the following does not seem to be needed
## any longer.  I left it here just for reference (in case it breaks
## again.
## 
## * * *
## 
## OK, in my case, `shutdown`, `reboot` and local media access functions
## were not available using the [MATE][mate] desktop.
## 
## To enable this I had to create/tweak the PolKit rules...
## 
## <script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/tweak-polkit-rules.sh?footer=minimal"></script>
## 
## * * *
## 
##  [void]: https://voidlinux.org "Void Linux"
##  [refind]: http://www.rodsbooks.com/refind/ "rEFInd bootloader"
##  [void-uefi]: https://wiki.voidlinux.org/Installation_on_UEFI,_via_chroot "Install void linux on UEFI via chroot"
##  [mate]: https://mate-desktop.org/ "MATE Desktop environment"
##  [getting-refind]: http://www.rodsbooks.com/refind/getting.html "rEFInd download page"
## 
#end-output
