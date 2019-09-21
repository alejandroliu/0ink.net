#!/bin/bash
#
#
set -euf -o pipefail
script=$(readlink -f "$0")

repourl=https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void
identdurl=https://raw.githubusercontent.com/TortugaLabs/autonom/master
mnt=/mnt
hmnt="$mnt"
svcdir="$mnt/etc/runit/runsvdir/default"

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
      elif [ x"$ln" = x"::begin-output" ] ; then
	output="echo"
      elif [ x"$ln" = x"::end-output" ] ; then
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
	-e 's!$identdurl!'"$identdurl!" \
	-e 's!$0!installer.sh!' \
	-e 's!$run!!' \
	-e 's!$mnt!!' \
	-e 's!$hmnt!'"$hmnt!" \
	-e 's!$svcdir!/var/service!'
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
	- desktop=no ; do not install desktop environment
	- desktop=mate : Install MATE dekstop environment
	- rsync.host=host : rsync backup server
	- rsync.secret=secret : rsync backup pre-shared-key
	- passwd=password : root password (prompt if not specified)
	- enc-passwd=encrypted : encrypted root password.
	- ovl=tar.gz : tarball containing additional files
	- pkgs=file : text file containing additional software to install
#end-output
	_EOF_
  exit 1
fi
sysdev="$1"
syshost="$2"
shift 2

if [ -d "$sysdev" ] ; then
  echo "$sysdev: is a directory"
  [ $(readlink -f "$sysdev") = "$mnt" ] && die 5 "Can not use $mnt"
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

if pw=$(check_opt "enc-passwd" "$@") ; then
  pwenc="false"
  pwline="$pw"
elif pw=$(check_opt "passwd" "$@") ; then
  pwenc="true"
  pwline="$pw"
else
  read -p "Enter root passwd: " pw
  pwenc="true"
  pwline="$pw"
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
  sleep 1
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
mount "${sysdev}3" $hmnt
mkdir $hmnt/boot
mount "${sysdev}1" $hmnt/boot
#end-output
elif [ -d "$sysdev" ] ; then
  mount --rbind "$sysdev" "$mnt"
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
## env XBPS_ARCH=x86_64-musl xbps-install -S -R http://alpha.de.repo.voidlinux.org/current/musl -r $hmnt base-system grub-x86_64-efi
## ```
##
## For glibc (untested)
## ```
## env XBPS_ARCH=x86_64 xbps-install -S -R http://alpha.de.repo.voidlinux.org/current -r $hmnt base-system grub-x86_64-efi
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
  voidurl="http://alpha.de.repo.voidlinux.org/current/musl"
else
  # GLIBC installation
  arch="x86_64"
  voidurl="http://alpha.de.repo.voidlinux.org/current"
fi
desktop=$(check_opt desktop "$@") || :
[ -z "$desktop" ] && desktop=mate

run="chroot $mnt"

echo y | env XBPS_ARCH="$arch" xbps-install -y -S -R "$voidurl" -r $mnt $(
  (wget -O- "$repourl/swlist.txt" 
  if ! check_opt noxwin "$@" >/dev/null 2>&1 ; then
    wget -O- "$repourl/swlist-xwin.txt"
    if is_valid_desktop "$desktop" ; then
      wget -O- "$repourl/swlist-$desktop.txt"
    fi
  fi
  if pkgs=$(check_opt pkgs "$@") ; then
    [ -f "$pkgs" ] && cat "$pkgs"
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
env XBPS_ARCH="$arch" xbps-install -y -S -R "$voidurl" -r $mnt intel-ucode unrar
#begin-output
##
## ## Enter the void chroot
##
## Upon completion of the install, we set up our chroot jail, and chroot into our mounted filesystem:
##
## ```
mount -t proc proc $hmnt/proc
mount -t sysfs sys $hmnt/sys
mount -o bind /dev $hmnt/dev
mount -t devpts pts $hmnt/dev/pts
cp -L /etc/resolv.conf $hmnt/etc/
## chroot $hmnt bash -il
## ```
##
## In order to verify our install, we can have a look at the directory structure:
##
## ```
$run ls -la
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
#end-output
if $pwenc ; then
  printf "$pwline\n$pwline\n" | $run passwd root
else
  $run usermod --password "$pwline" root
fi
#begin-output
## ```
## passwd root
$run chown root:root /
$run chmod 755 /
## ```
##
## Since I am a `bash` convert, I would do this:
##
## ```
$run xbps-alternatives --set bash
## ```
##
## Create the `hostname` for the new install:
##
## ```
## echo <HOSTNAME> > /etc/hostname
#end-output
echo $syshost > $mnt/etc/hostname
#begin-output
## ```
##
## Edit our `/etc/rc.conf` file, like so:
##
## ```
#end-output
(cat <<:end-output
#begin-output
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
:end-output
) | sed \
	-e 's!<HOSTNAME>!'"$syshost"'!' \
	> $mnt/etc/rc.conf 
#begin-output
## ```
##
## Also, modify the `/etc/fstab`:
##
## ```
#end-output
(cat <<:end-output
#begin-output
#
# See fstab(5).
#
# <file system>	<dir>	<type>	<options>		<dump>	<pass>
tmpfs		/tmp	tmpfs	defaults,nosuid,nodev   0       0
LABEL=EFI	/boot	vfat	rw,fmask=0133,dmask=0022,noatime,discard  0 2
LABEL=voidlinux	/	xfs	rw,relatime,discard	0 1
LABEL=swp0 	swap	swap	defaults		0 0
:end-output
) > $mnt/etc/fstab
#begin-output
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
#end-output
if check_opt glibc "$@" ; then
#begin-output
## ```
$run xbps-reconfigure -f glibc-locales
## ```
#end-output
fi
#begin-output
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
## The version I am using right now can be found here: [v0.11.4 BOOTX64.EFI]($repourl/BOOTX64.EFI)
##
## Create kernel options files `/boot/cmdline`:
## 
## ```
## root=LABEL=voidlinux ro quiet
## 
## ```
#end-output
mkdir -p $mnt/boot/EFI/BOOT
wget -O$mnt/boot/EFI/BOOT/BOOTX64.EFI $repourl/BOOTX64.EFI
echo "root=LABEL=voidlinux ro quiet" > $mnt/boot/cmdline
#begin-output
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
## <script src="https://gist-it.appspot.com/$repourl/mkmenu.sh?footer=minimal"></script>
## 
## Add the following scripts to: 
## 
## - `/etc/kernel.d/post-install/99-refind`
## - `/etc/kernel.d/post-remove/99-refind`
## 
## <script src="https://gist-it.appspot.com/$repourl/hook.sh?footer=minimal"></script>
## 
## Make sure they are executable.  This is supposed to re-create
## menu entries whenever the kernel gets upgraded.
##
#end-output
wget -O$mnt/boot/mkmenu.sh $repourl/mkmenu.sh
wget -O- $repourl/hook.sh | tee $mnt/etc/kernel.d/post-{install,remove}/99-refind
chmod 755 $mnt/etc/kernel.d/post-{install,remove}/99-refind
#begin-output
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
## drwxr-xr-x  3 root root 4096 Jan 31 15:22 5.2.13_1
## ```
## 
## And this script to create boot files:
## 
## ```
## xbps-reconfigure -f linux5.2
## ```
##
#end-output
kver=$($run xbps-query linux | awk '$1 == "pkgver:" { print $2 }' | sed -e 's/linux-//' -e 's/_.*$//')
$run xbps-reconfigure -f linux${kver}
#begin-output
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
## umount -R $hmnt
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
## ln -s /etc/sv/{consolekit,lxdm} /var/service
## ```
#end-output
common_svcs="sshd acpid chronyd crond uuidd statd rpcbind autofs"
if check_opt noxwin "$@" ; then
  net_svcs="dhcpcd"
  ws_svcs=""
else
  net_svcs="dbus NetworkManager"
  #ws_svcs="consolekit lxdm polkitd rtkit"
  ws_svcs="consolekit slim"
fi
for svc in $common_svcs $net_svcs $ws_svcs
do
  [ -d /etc/sv/$svc ] && ln -s /etc/sv/$svc $svcdir
done
#begin-output
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
#end-output
echo "%admins ALL=(ALL) ALL" >> $mnt/etc/sudoers
#begin-output
## 
## ## Logging
## 
## Source: [Logging](https://voidlinux.org/faq/#Logging)
## 
## Optional:
##
## ```
## usermod -aG socklog <your username>
## ```
##
## Because I like to have just a single directory for everything and use
## `grep`, I do the following:
##
## ```
## rm -rf /var/log/socklog/?*
## mkdir /var/log/socklog/everything
## ln -s socklog/everything/current /var/log/messages.log
## ```
#end-output
find $mnt/var/log/socklog -maxdepth 1 -mindepth 1 -print0 | xargs -0 rm -rf
mkdir $mnt/var/log/socklog/everything
ln -s socklog/everything/current $mnt/var/log/messages.log
#begin-output
##
## Create the file `/var/log/socklog/everything/config` with these
## contents:
##
## ```
## +*
## u172.17.1.8:514
## ```
##
## Enable daemons...
##
## ```
## ln -s /etc/sv/socklog-unix /var/service/
## ln -s /etc/sv/nanoklogd /var/service/
## ```
##
## Reload `svlogd` (if it was already running)
##
## ```
## killall -1 svlogd
## ```
##
#end-output
mkdir -p $mnt/var/log/socklog/everything
cat > $mnt/var/log/socklog/everything/config <<-_EOF_
	+*
	u172.17.1.8:514
	_EOF_
ln -s /etc/sv/{socklog-unix,nanoklogd} $svcdir
#begin-output
##
## ## System backups
##
## For [void linux][void] I prefer to re-install instead to do a full
## backup.  A few selected files are backed-up.  This is done with this
## [script]($repourl/rsvault.sh)
##
## To install, copy that script to `/usr/local/sbin` and make it
## executable.
##
## Create a cronjob in `/etc/cron.daily/rsvault` to enable.
##
## Configure server information in `/etc/rsync.cfg`
##
## ```
## rsync_host="<server>"
## rsync_passwd="<passwd>
## ```
##
## Make sure you set permissions accordingly:
##
## - `chmod 600 /etc/rsync.cfg`
##
## Create hardlinks to files that you would like to protect in
## `/etc/rsync.vault`.  For example:
##
## - `/etc/crypttab`
## - `/crypto_keyfile.bin`
## - `/etc/hosts` #: if using for ad blocking
##
## Alternatively, you can do a full backup with this
## [script]($repourl/os-backup.sh).
##
#end-output
if check_opt "rsync.secret" "$@" ; then
  rsync_host=$(check_opt "rsync.host" "$@") || rsync_host=vms3 # default rsync server
  wget -O$mnt/usr/local/sbin/rsvault $repourl/rsvault.sh
  printf '#!/bin/sh\n/usr/local/sbin/rsvault\n' > $mnt/etc/cron.daily/rsvault
  cat > $mnt/etc/rsync.cfg <<-_EOF_
	rsync_passwd=$(check_opt "rsync.secret" "$@")
	rsync_host=$rsync_host
	_EOF_
  chmod 600 $mnt/etc/rsync.cfg
  chmod 755 $mnt/usr/local/sbin/rsvault $mnt/etc/cron.daily/rsvault
  mkdir -p $mnt/etc/rsync.vault
fi
#begin-output
##
## ## Identd server
##
## I am using this [identd server]($identdurl/an_identd.py)to support
## a simple Single-Sign-On scheme.
##
## ```
mkdir -p $mnt/etc/sv/an_identd/log
wget -O$mnt/usr/local/sbin/an_identd $identdurl/an_identd.py
wget -O$mnt/etc/sv/an_identd/run $identdurl/etc-sv-an_identd/run
wget -O$mnt/etc/sv/an_identd/log/run $identdurl/etc-sv-an_identd/log/run
chmod 755 $mnt/usr/local/sbin/an_identd $mnt/etc/sv/an_identd/run $mnt/etc/sv/an_identd/log/run
ln -s /etc/sv/an_identd $svcdir
## ```
##
## ## Configure keyboard
##
## Create configuration file: `/etc/X11/xorg.conf.d/30-keyboard.conf`
##
## ```
#end-output
if [ -d $mnt/etc/X11 ] ; then
  mkdir -p $mnt/etc/X11/xorg.conf.d
  cat >$mnt/etc/X11/xorg.conf.d/30-keyboard.conf <<:end-output
#begin-output  
Section "InputClass"
    Identifier "keyboard-all"
    Option "XkbLayout" "us"
    # Option "XkbModel" "pc105"
    # Option "XkbVariant" "altgr-intl"
    Option "XkbVariant" "intl"
    # MatchIsKeyboard "on"
EndSection
:end-output
fi
#begin-output  
## ```
##
## This makes the `intl` for the `XkbVariant` the system-wide default.
##
## Since, as a programmer I prefer the `altgr-intl` variant, then I
## run this in my de desktop environment startup to override the
## default:
##
## ```
## setxkbmap -rules evdev -model evdev -layout us -variant altgr-intl
## ```
##
## ## Tweak LXDM
##
## MATE under Void Linux uses [LXDM][lxdm] as the Display Manager in the LiveCD.
##
## Configuration is located in `/etc/lxdm/lxdm.conf`.
##
## Things to change:
##
## - `[base]`
##   - `session=/usr/bin/mate-session`
##   - Change the default session to a suitable default (the system
##     default is LXDE).
## - `[display]`
##   - `lang=0`
## - `[userlist]`
##   - `disable=1`
##
#end-output
if [ -f $mnt/etc/lxdm/lxdm.conf ] ; then
  sed \
	-i-void \
	-e 's/lang=.*/lang=0/' \
	-e '/session=/a session=/usr/bin/mate-session' \
	$mnt/etc/lxdm/lxdm.conf
fi
#begin-output
##
## After the user logs on, [lxdm][lxdm] seems to run `/etc/lxdm/Xsession`
## to set-up the session.  Amongst other things, [lxdm][lxdm] sources
## all of the following files, in order:
##
## - `/etc/profile`
## - `~/.profile`
## - `/etc/xprofile`
## - `~/.xprofile`
##
## These files can be used to set session environment variables and to
## start services which must set certain environment variables in order
## for clients in the session to be able to use the service, like
## ssh-agent.
##
## ## Using SLIM
##
## I have switched to [SLiM][SLiM] as the display manager.  This is
## configured in `/etc/slim.conf`.
##
#end-output
if [ -f $mnt/etc/slim.conf ] ; then
  sed \
	-i-void \
	-e 's!^login_cmd.*!login_cmd exec /bin/sh -l /etc/X11/Xsession %session!' \
	$mnt/etc/slim.conf
  mkdir -p $mnt/etc/X11
  wget -O$mnt/etc/X11/Xsession $repourl/Xsession
fi
#begin-output
##
## ## Tweaks and Bug-fixes
## 
## ### power button handling
## 
## This patch prevents the /etc/acpi/handler.sh to handle the power button
## instead, letting the Desktop Environment handle the event.
## 
## <script src="https://gist-it.appspot.com/$repourl/acpi-handler.patch?footer=minimal"></script>
##
#end-output
wget -O- $repourl/acpi-handler.patch | patch -b -z -void -d $mnt/etc/acpi
#begin-output
## 
## ### rtkit spamming logs
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
##  [lxdm]: https://wiki.lxde.org/en/LXDM "LXDM Display Manager"
##  [SLiM]: https://github.com/iwamatsu/slim "Simple Login Manager"
## 
#end-output

# customization stuff...
if ovl=$(check_opt ovl "$@") ; then
  tar -C $mnt -zxvf "$ovl"
fi

cat <<__EOF__
Manual post installation tasks:

- Check /boot/cmdline and make sure nothing else is missing
  - Update and run: chroot $mnt xbps-reconfigure -f linux5.2
- Create users or run tlrealm.sh script
$(
  if check_opt "rsync.secret" "$@" >/dev/null 2>&1 ; then
    echo "- Create backup hardlinks in /etc/rsync.vault"
    echo "- Make sure the shared secret is properly configured"
  fi
)
- don't forget to unmount
  # umount -R $mnt
__EOF__


