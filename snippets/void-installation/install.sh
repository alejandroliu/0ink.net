#!/bin/bash
#
#
set -euf -o pipefail
script=$(readlink -f "$0")

repourl="https://github.com/alejandroliu/0ink.net/raw/master/snippets/void-installation"
embedopts='?style=github\&showBorder=on\&showLineNumbers=on\&showFileMeta=on\&showCopy=on\&fetchFromJsDelivr=on\&'
embedurl="https://tortugalabs.github.io/embed-like-gist/embed.js${embedopts}target="

mnt=/mnt
hmnt="$mnt"
svcdir="$mnt/etc/runit/runsvdir/default"

if [ $# -eq 0 ] ; then
  # Show documentation...
  repourl=$(echo "$repourl"|sed -e 's!/raw/!/blob/!')

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
	-e 's!$embedurl!'"$embedurl!" \
	-e 's!$0!installer.sh!' \
	-e 's!$run!!' \
	-e 's!$mnt!!' \
	-e 's!$hmnt!'"$hmnt!" \
	-e 's!$svcdir!/var/service!'
  exit 0
fi

check_opt() {
  local out=echo
  if [ x"$1" = x"-q" ] ; then
    out=:
    shift
  fi
  local flag="$1" ; shift
  for j in "$@"
  do
    if [ x"${j%=*}" = x"$flag" ] ; then
      $out "${j#*=}"
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
## I made the switch to [void linux][void].  Except for compatibility
## issues around `glibc`, it works quite well.  Most compatibility
## I have worked around with a combination of `Flatpak`s, `chroot`s and
## `namespaces`.
##
## The high lights of [void linux][void]:
##
## - musl build - which is very lightweigth
## - Does not depend on `systemd`
## - a reasonable selection of software packages
##
## I have tweaked the installation on my computers to use UEFI and thus
## I am using [rEFInd][refind] instead of grub.  This is because it makes
## doing bare metal backups and restore just a simple file copy.
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
	Usage: $0 _/dev/sdx_ _hostname_ [options]

	- _sdx_: Block device to install to or
	  - --image=filepath[:size] to create a virtual disc image
	  - --imgset=filebase[:size] to create a virtual filesystem image set
	  - --dir=dirpath to create a directory
	- _hostname_: Hostname to use

	Options:
	- mem=memory : memory size, defaults computed from /proc/meminfo, uses numfmt to parse values
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
#end-output
	_EOF_
  exit 1
fi
#begin-output
## ```
##
## ### Command line examples
##
## - sudo sh install.sh --dir=$HOME/vx9 vx9 mem=4G glibc passwd=1234567890 cache=$HOME/void-cache xen
## - sudo sh install.sh --dir=$HOME/vx1 vx1 mem=4G glibc passwd=1234567890 cache=$HOME/void-cache xen
## - sudo sh install.sh --dir=$HOME/vx11 vx11 mem=4G       passwd=1234567890 cache=$HOME/void-cache xen
##
#end-output



sysdev="$1"
syshost="$2"
shift 2

mem=$(check_opt mem "$@") || :
if [ -n "$mem" ] ; then
  mem=$(numfmt --from=iec --to-unit=1024 "$mem")
  [ -z "$mem" ] && die 1 "Invalid number for mem"
else
  mem=$(awk '$1 == "MemTotal:" { print $2 }' /proc/meminfo)
fi

case "$sysdev" in
--image=*)
  # The sysdev is actually a virtual disk image...
  imgname=${sysdev#--image=}
  imgset=false
  if (echo "$imgname" | grep -q :) ; then
    imgsz=$(numfmt --to-unit=1024 --from=iec $(echo "$imgname" | cut -d: -f2 ))
    imgname=$(echo "$imgname" | cut -d: -f1)
  else
    imgsz=$(expr $(numfmt --to-unit=1024 --from=iec 500M) + $(numfmt --to-unit=1024 --from=iec 4G) + $(expr $mem + $(expr $mem / 2)) + 1024)
  fi
  echo "$imgname: ${imgsz}K"
  truncate -s 0 "$imgname" # Make sure this is zero size so we can create a sparse file
  truncate -s "${imgsz}K" "$imgname"
  ;;
--imgset=*)
  # the sysdev is a virtual filesystem image set
  imgname=${sysdev#--imgset=}
  imgset=true
  if (echo "$imgname" | grep -q :) ; then
    imgsz=$(numfmt --to-unit=1024 --from=iec $(echo "$imgname" | cut -d: -f2 ))
    imgname=$(echo "$imgname" | cut -d: -f1)
  else
    imgsz=$(numfmt --to-unit=1024 --from=iec 4G)
  fi
  echo "$imgname: ${imgsz}K"
  truncate -s 0 "${imgname}1"
  truncate -s 0 "${imgname}2"
  truncate -s 0 "${imgname}3"
  ;;
--dir=*)
  # Create a directory...
  imgname=""
  sysdev="${sysdev#--dir=}"
  [ $(readlink -f "$sysdev") = "$mnt" ] && die 5 "Can not use $mnt"
  mkdir "$sysdev"
  ;;
*)
  imgname=""
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
  ;;
esac

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
##
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


partition_sys() {
  local csize="$1" drive="$2"
  local swapsz=$(expr $mem + $(expr $mem / 2))
  local uefisz=$(numfmt --to-unit=1024 --from=iec 500M)
  local rootsz=$(numfmt --to-unit=1024 --from=iec 4G)
  local req=$(expr $uefisz + $swapsz + $rootsz)
  local syslinux_lib=/usr/lib/syslinux

  #~ echo csize=$(numfmt --to=iec --from=iec ${csize}K)
  #~ echo req=$(numfmt --to=iec --from=iec ${req}K)

  # Partition block device...
  [ $req -gt $csize ] && die 2 "$drive is too small ($(numfmt --to=iec --from=iec ${csize}K) < $(numfmt --to=iec --from=iec ${req}K))" || :

  if check_opt bios "$@" ; then
    echo "Using DOS disklabel for BIOS boot"
    sfdisk_label=dos
  else
    echo "Using GPT disklabel for UEFI boot"
    sfdisk_label=gpt
  fi

  sfdisk "$drive" <<-_EOF_
	  label: ${sfdisk_label}

	  ,${uefisz}K,U,*
	  ,${swapsz}K,S,
	  ,,L,
	_EOF_

  if check_opt bios "$@" ; then
    # BIOS: Install MBR
    echo "Installing BIOS MBR for $drive"
    dd bs=440 count=1 conv=notrunc if=$syslinux_lib/mbr.bin of="${drive}"
    sleep 1
  fi
}

if [ -n "$imgname" ] ; then
  if $imgset ; then
    syspart1="${imgname}1"
    syspart2="${imgname}2"
    syspart3="${imgname}3"
    truncate -s 500M "$syspart1"
    truncate -s $(expr $mem + $(expr $mem / 2))K "$syspart2"
    truncate -s ${imgsz}K "$syspart3"
  else
    echo "Setting up virtual disc image: $imgname"
    partition_sys "$imgsz" "$imgname"

    loops=$(kpartx -a -v "$imgname" | awk '{print $3}')
    syspart1=/dev/mapper/$(echo "$loops" | head -1)
    syspart2=/dev/mapper/$(echo "$loops" | head -2 | tail -1)
    syspart3=/dev/mapper/$(echo "$loops" | head -3 | tail -1)
  fi
  do_mkfs=true
elif [ -b "$sysdev" ] ; then
  echo "Partitioning physical disc: $sysdev"
  partition_sys $(expr $(blockdev --getsz "$sysdev") / 2) "$sysdev"

  syspart1="${sysdev}1"
  syspart2="${sysdev}2"
  syspart3="${sysdev}3"

  do_mkfs=true
else
  do_mkfs=false
fi

#begin-output
##
## This is on a USB thumb drive.  The data I keep on an internal disk.
##
## Now we create the filesystems:
##
## ```
## mkfs.vfat -F 32 -n EFI /dev/xda1
## mkswap -L swp0 /dev/xda2
## mkfs.xfs -f -L voidlinux /dev/xda3
## ```
##
#end-output

if $do_mkfs ; then
  sleep 3
  echo "Making filesystems"
  sysfsname1="EFI$RANDOM"
  mkfs.vfat -F 32 -n "$sysfsname1" "${syspart1}"
  sysfsname2="swp$RANDOM"
  mkswap -L "$sysfsname2" "${syspart2}"
  sysfsname3="void.$RANDOM"
  mkfs.xfs -f -L "$sysfsname3" "${syspart3}"

  ### WE DO A BIOS COMPATIBLE THING WITH SYSLINUX
  if check_opt bios "$@" ; then
    echo "Installing SYSLINUX for BIOS boot on $syspart1"
    syslinux --install --force "$syspart1" || :
  fi
fi


#begin-output
##
## We're now ready to mount the volumes, making any necessary mount point directories along the way (the sequence is important, yes):
##
## ```
## mount /dev/xda3 $hmnt
## mkdir $hmnt/boot
## mount /dev/xda1 $hmnt/boot
## ```
##
#end-output
if $do_mkfs ; then
  mount "${syspart3}" $hmnt
  mkdir $hmnt/boot
  mount "${syspart1}" $hmnt/boot
elif [ -d "$sysdev" ] ; then
  mount --rbind "$sysdev" "$mnt"
fi

#
# Use/Re-use a download cache
#
if cache=$(check_opt cache "$@") ; then
  if [ -d "$cache" ] ; then
    mkdir -m 0755 $hmnt/var
    mkdir -m 0700 $hmnt/var/cache $hmnt/var/cache/xbps
    mount --bind "$cache" $hmnt/var/cache/xbps
  else
    echo "$cache : cache dir does not exist"
  fi
fi


#begin-output
##
## ## Installing Void
##
## So we do a targeted install:
##
## For musl-libc
##
## ```
## env XBPS_ARCH=x86_64-musl xbps-install -S -R http://alpha.de.repo.voidlinux.org/current/musl -r $hmnt base-system grub-x86_64-efi
## ```
##
## For glibc
## ```
## env XBPS_ARCH=x86_64 xbps-install -S -R http://alpha.de.repo.voidlinux.org/current -r $hmnt base-system grub-x86_64-efi
## ```
##
## But actually, for the package list I have been using these lists:
##
## <script src="$embedurl$repourl/swlist.txt"></script>
## <script src="$embedurl$repourl/swlist-xwin.txt?footer=minimal"></script>
## <script src="$embedurl$repourl/swlist-mate.txt?footer=minimal"></script>
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
if check_opt nodesktop "$@" >/dev/null 2>&1 ; then
  desktop=no
fi

run="chroot $mnt"

extra_pkgs() {
  local fp pkgs=$(check_opt pkgs "$@") || return 0

  for fp in $(echo $pkgs | tr , ' ')
  do
    if [ -f "$fp" ] ; then
      cat "$fp"
      continue
    fi
    case "$fp" in
      http://*|https://*|ftp://*) wget -O- "$fp" ; continue ;;
    esac
    echo "$fp"
  done
}

echo y | env XBPS_ARCH="$arch" xbps-install -y -S -R "$voidurl" -r $mnt $(
  (wget -O- "$repourl/swlist.txt"
  if ! check_opt noxwin "$@" >/dev/null 2>&1 ; then
    wget -O- "$repourl/swlist-xwin.txt"
    if is_valid_desktop "$desktop" ; then
      wget -O- "$repourl/swlist-$desktop.txt"
    fi
  fi
  extra_pkgs "$@"
  )| sed -e 's/#.*$//'
)
#begin-output
## ### Software selection notes
##
## - For time synchronisation (ntp) we ae choosing `chrony` as it is
##   reputed to be more secure that `ntpd` and more compliant than
##   `openntpd`.
## - We are using the default configuration, which should be OK.  Uses
##   `pool.ntp.org` for the time server which would use a suitable
##   default.
## - For `cron` we are using `dcron`.  It is full featured (i.e.
##   compatibnle with `cron` and it can handle power-off situations,
##   while being the most light-weight option available.
##   See: [VoidLinux FAQ: Cron](https://voidlinux.org/faq/#cron)
## - Includes `autofs` and `nfs-utils` for network filesystems and
##   automount support.
##
## ## nonfree software and other repositories
##
## Additional repositories are available to support either
## non-free software and in the case of glibc, multilib (32 bit)
## binaries.
##
## To enable under the musl version:
##
## ```
## env XBPS_ARCH="$arch" xbps-install -y -S -R "$voidurl" -r $hmnt void-repo-nonfree
## ```
##
## For glibc:
##
## ```
## env XBPS_ARCH="$arch" xbps-install -y -S -R "$voidurl" -r $hmnt void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
## ```
##
## Then you can install non-free software.
##
#end-output
if ! check_opt glibc "$@" ; then
 env XBPS_ARCH="$arch" xbps-install -y -S -R "$voidurl" -r $hmnt void-repo-nonfree
else
  env XBPS_ARCH="$arch" xbps-install -y -S -R "$voidurl" -r $hmnt void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
fi
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
##  passwd root
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
## #
## # See fstab(5).
##
## # <file system>	<dir>	<type>	<options>		<dump>	<pass>
## tmpfs		/tmp	tmpfs	defaults,nosuid,nodev   0       0
## LABEL=EFI	/boot	vfat	rw,fmask=0133,dmask=0022,noatime,discard  0 2
## LABEL=voidlinux	/	xfs	rw,relatime,discard	0 1
## LABEL=swp0 	swap	swap	defaults		0 0
## ```
#end-output
if $do_mkfs ; then
  (cat <<-_EOF_
	#
	# See fstab(5).
	#
	# <file system>	<dir>	<type>	<options>		<dump>	<pass>
	tmpfs		/tmp	tmpfs	defaults,nosuid,nodev   0       0
	LABEL=$sysfsname1	/boot	vfat	rw,fmask=0133,dmask=0022,noatime,discard  0 2
	LABEL=$sysfsname3	/	xfs	rw,relatime,discard	0 1
	LABEL=$sysfsname2 	swap	swap	defaults		0 0
	_EOF_
  ) > $mnt/etc/fstab
elif check_opt xen "$@" ; then
  (cat <<-_EOF_
	#
	# See fstab(5).
	#
	# <file system>	<dir>	<type>	<options>		<dump>	<pass>
	tmpfs		/tmp	tmpfs	defaults,nosuid,nodev   0       0
	/dev/xvda	/	xfs	rw,relatime,discard	0 1
	#/dev/xvdb	/home	xfs	rw,relatime,discard	0 2
	#/dev/xvdc	swap	swap 	defaults		0 0
	_EOF_
  ) > $mnt/etc/fstab
else
  (cat <<-_EOF_
	#
	# See fstab(5).
	#
	# <file system>	<dir>	<type>	<options>		<dump>	<pass>
	tmpfs		/tmp	tmpfs	defaults,nosuid,nodev   0       0
	#LABEL=EFI	/boot	vfat	rw,fmask=0133,dmask=0022,noatime,discard  0 2
	#LABEL=void	/	xfs	rw,relatime,discard	0 1
	#LABEL=swp0 	swap	swap	defaults		0 0
	_EOF_
  ) > $mnt/etc/fstab
fi
#begin-output
##
## For a removable drive I include the line:
##
## ```
## LABEL=volume	/media/blahblah xfs	rw,relatime,nofail 0 0
## ```
##
## The important setting here is **nofail**.  When the drive is
## available it gets mounted.  If not, the **nofail** prevents
## this to cause the boot sequence to stop.
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

# Default Kernel command line
if $do_mkfs ; then
  echo "root=LABEL=$sysfsname3 ro quiet" > $mnt/boot/cmdline
elif check_opt xen "$@" ; then
  echo "root=/dev/xvda ro" > $mnt/boot/cmdline
else
  echo "root=LABEL=voidlinux ro quiet" > $mnt/boot/cmdline
fi

if ! check_opt bios "$@" ; then
  echo "Installing UEFI files"
  mkdir -p $mnt/boot/EFI/BOOT
  wget -O$mnt/boot/EFI/BOOT/BOOTX64.EFI $repourl/BOOTX64.EFI
fi

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
## <script src="$embedurl$repourl/mkmenu.sh"></script>
##
## Add the following scripts to:
##
## - `/etc/kernel.d/post-install/99-refind`
## - `/etc/kernel.d/post-remove/99-refind`
##
## <script src="$embedurl$repourl/hook.sh"></script>
##
## Make sure they are executable.  This is supposed to re-create
## menu entries whenever the kernel gets upgraded.
##
#end-output

echo "Installinng boot menu generator"
wget -O$mnt/boot/mkmenu.sh $repourl/mkmenu.sh
wget -O- $repourl/hook.sh | tee $mnt/etc/kernel.d/post-{install,remove}/99-bootmenu
chmod 755 $mnt/etc/kernel.d/post-{install,remove}/99-bootmenu

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
echo -n 'Enabling services:'
for svc in $common_svcs $net_svcs $ws_svcs
do
  s='!'
  if [ -d $mnt/etc/sv/$svc ] ; then
    ln -s /etc/sv/$svc $svcdir && s=''
  fi
  echo -n " $s$svc"
done
echo ''

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
## ## Using SLIM
##
## I have switched to [SLiM][SLiM] as the display manager.  This is
## configured in `/etc/slim.conf`.
##
## Specifically, I update the login_cmd to be the following:
##
## ```
## login_cmd exec /bin/sh -l /etc/X11/Xsession %session
## ```
##
## And have a custom [Xsession]($repourl/Xsession) script.
##
#end-output
if [ -f $mnt/etc/slim.conf ] ; then
  sed \
	-i-void \
	-e 's!^login_cmd.*!login_cmd exec /bin/sh -l /etc/X11/Xsession %session!' \
	$mnt/etc/slim.conf
  mkdir -p $mnt/etc/X11
  wget -O$mnt/etc/X11/Xsession $repourl/Xsession
  chmod 755 $mnt/etc/X11/Xsession
fi
#begin-output
##
## ## Tweaks and Bug-fixes
##
## ### /etc/machine-id or /var/lib/dbus/machine-id
##
## Because we don't use `systemd`, we need to create `/etc/machine-id`
## and `/var/lib/dbus/machine-id`.
## manually.  This is only needed for desktop systems.
##
## See [this article][machineid] for more
## info.
##
#end-output
if is_valid_desktop "$desktop" ; then
#begin-output
## ```
  dbus-uuidgen | tee $mnt/etc/machine-id /var/lib/dbus/machine-id
## ```
#end-output
fi
#begin-output

## ### power button handling
##
## This patch prevents the /etc/acpi/handler.sh to handle the power button
## instead, letting the Desktop Environment handle the event.
##
## It does it by checking if the Desktop Environment power manager
## (in this case `mate-power-manager`) is running.  If it is, then
## it will exit.
##
## <script src="$embedurl$repourl/acpi-handler.patch"></script>
##
#end-output
wget -O- $repourl/acpi-handler.patch | patch -b -z -void -d $mnt/etc/acpi
#begin-output
## ### rtkit spamming logs
##
## Apparently, `rtkit` requres an `rtkit` user to exist.  Otherwise it
## will spam the logs with error messages.  To correct use this command:
##
## ```
## useradd -r -s /sbin/nologin rtkit
## ```
##
## ### xen tweaks
##
## For xen we need to make some adjustments...
##
## 1. Tweak block device references.
##    - `/etc/fstab` : mount xvda and other devices
##    - `/boot/cmdline` : get the right xvda root device
## 2. Enable disable services
##    - Disable: `slim`, `agetty-ttyX`
##    - Enable: `agetty-hvc0`
##    - Decide if you want to use `NetworkManager` or `dhcpcd`.
##
## Normally, I would create a tarball image to transfer over, in order
## for the image to work properly you need to save `capabilities`.
##
#end-output
if check_opt xen "$@" ; then
  echo "Applying xen specific service tweaks"
  for svc in slim
  do
    rm -f "$svcdir/$svc"
  done
  for notty in $(seq 1 9)
  do
    rm -f "$svcdir/agetty-tty$notty"
  done
  con=hvc0
  rm -f "$svcdir/agetty-$con"
  ln -s /etc/sv/agetty-$con "$svcdir/agetty-$con"

  # Saving capabilities...
  echo "Saving capabilities"
  find "$mnt" -xdev -printf '%y %p\n' | sed -e "s!^\\(.\\) $mnt/!\\1 !" | (while read t fpath
  do
    [ x"$t" != x"f" ] && continue
    echo "$fpath"
  done) | tr '\n' '\0' | ( cd "$mnt" ; xargs -0 getcap ) > $mnt/.caps
fi
#begin-output

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
## <script src="$embedurl$repourl/_attic_/tweak-polkit-rules.sh"></script>
##
## * * *
##
##  [void]: https://voidlinux.org "Void Linux"
##  [refind]: http://www.rodsbooks.com/refind/ "rEFInd bootloader"
##  [void-uefi]: https://wiki.voidlinux.org/Installation_on_UEFI,_via_chroot "Install void linux on UEFI via chroot"
##  [mate]: https://mate-desktop.org/ "MATE Desktop environment"
##  [getting-refind]: http://www.rodsbooks.com/refind/getting.html "rEFInd download page"
##  [SLiM]: https://github.com/iwamatsu/slim "Simple Login Manager"
##  [machienid]: https://wiki.debian.org/MachineId
##
#end-output

# customization stuff...
if ovl=$(check_opt ovl "$@") ; then
  tar -C $mnt -zxvf "$ovl"
fi
if post=$(check_opt post "$@") ; then
  "$post" $mnt "$kver"
fi

cat <<__EOF__
Manual post installation tasks:

- Check /boot/cmdline and make sure nothing else is missing
  - Update and run: chroot $mnt xbps-reconfigure -f linux${kver}
- don't forget to unmount
  # umount -R $mnt
$(
  if [ -n "$imgname" ] ; then
    echo "  # kpartx -d -v $imgname"
  fi
)
__EOF__


#
# re-image
#
# - /etc/hostname
# - /etc/rc.conf : HOSTNAME=xxxx
# - /etc/shadow : passwords?
# - /etc/machine-id and /var/lib/dbus/machine-id
#     dbus-uuidgen | tee $mnt/etc/machine-id /var/lib/dbus/machine-id
