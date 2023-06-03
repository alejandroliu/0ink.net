#!/bin/sh
set -euf -o pipefail
# requires: jc jq qemu
#
# run: ... (remove reset)
# Get config from boot partition/raw image
# https://github.com/raspberrypi/documentation/blob/develop/documentation/asciidoc/computers/configuration/boot_folder.adoc
# Note: First partition.
# Use sfdisk to get the first partition
#  dd [--image-opts] [-U] [-f fmt] [-O output_fmt] [bs=block_size] [count=blocks] [skip=blocks] if=input of=output
#  1 -- read bootsectors qemu-img dd -f raw -O raw bs=512 count=8192 if=2022-09-22-raspios-bullseye-arm64-lite.img of=bs.raw
#  2 -- use sfdisk to check Units and start end sectors for first partition
# Check if there is a partition table
#   sfdisk -J test.img | jq '.partitiontable.label // ""'
# Get start of 1st partition otherwise unpartitioned disk
#   sfdisk -J bs.raw | jq -r '.partitiontable.partitions[0].start // ""'
# Use jc or similar to read config.txt
  # get base format
  # check if base is raw filesys and dos part
  # blkid -o value file | full

die() {
  echo "$@" 1>&2
  exit $1
}

stline() {
  set +x
  while read -r L
  do
    printf '\r'
    echo -n "$L"
    printf '\033[K'
  done
  [ $# -eq 0 ] && set - "Done"
  if [ -z "$*" ] ; then
    echo -n '\r\033[K\r'
  else
    printf '\r%s\033[K\r\n' "$*"
  fi
}

runst() {
  "$@" 2>&1 | stline "$1: done"
}

img_format() {
  qemu-img info "$1" | awk '$1 == "file" && $2 == "format:" { print $3 }'
}

img_fixext() {
  echo -n "$2" | sed -e 's/\.img$//' -e 's/\.qcow2$//'
  case "$1" in
  raw) echo '.img' ;;
  *) echo ".$1" ;;
  esac
}

prep_generic() {
  # Generic preping
  local imgsz="$1" oformat="$2" label="$3" compress="$4" img="$5"
  [ ! -f "$img" ] && die 58 "$img: not found"

  #~ # Check if this img is compressed
  local dimg="$img" decoder="" rc=0
  case "$img" in
  *.xz)
    dimg=$(echo "$img" | sed -e 's/\.xz$//')
    decoder="xz -dv"
    ;;
  *.gz)
    dimg=$(echo "$img" | sed -e 's/\.gz$//')
    decoder="gzip -d"
    ;;
  *.zip)
    dimg=$(echo "$img" | sed -e 's/\.zip$//')
    decoder="gzip -d"
    ;;
  *.bz2)
    dimg=$(echo "$img" | sed -e 's/\.bz2$//')
    decoder="bzip2 -d"
    ;;
  esac

  if [ -n "$decoder" ] ; then
    if ! $decoder <"$img" >"$dimg" ; then
      rm -fv "$dimg"
      return 1
    fi
  fi
  local imgfmt=$(img_format "$dimg")
  if [ -z "$imgfmt" ] ; then
    [ -n "$decoder" ] && rm -fv "$dimg"
    die 60 "$img: Unable to determine format"
  fi

  if [ "$oformat" = "$imgfmt" ] && [ -z "$imgsz" ] && [ -z "$compress" ] ; then
    [ -z "$decoder" ] && echo "$img: prep skipped" 1>&2
    return 0
  fi

  (
    local ofile=$(img_fixext "$oformat" "$dimg")
    ([ x"$ofile" = x"$dimg" ] || [ -z "$ofile" ]) && die 76 "$img: Unable to generate valid output file"

    qemu-img convert -p $compress -f $imgfmt -O $oformat "$dimg" "$ofile"
    [ -n "$imgsz" ] && qemu-img resize "$ofile" $imgsz
  ) || rc=$?
  [ -n "$decoder" ] && rm -fv "$dimg"
  return $rc
}

prep_alpine() {
  # Alpine specific preping
  local imgsz="$1" oformat="$2" label="$3" compress="$4" img="$5"

  img=$(echo "$img" | sed -e 's/\.tar\.gz$//')
  [ ! -f "$img.tar.gz" ] && die "$img: missing tarball"

  local w=$(mktemp -p "$(dirname "$img")" -d) rc=0
  (
    mkdir "$w/root"
    runst tar -C "$w/root" -zxvf "$img.tar.gz"

    if [ -z "$imgsz" ] ; then
      imgsz=$(du -sk "$w/root"  | awk '{print $1}')
      imgsz=$(expr $(expr $imgsz + 1) '*' 3 / 2)k
      echo "Calculated imgsz: $imgsz"
    fi

    # Create raw image
    qemu-img create -f raw "$w/img" $imgsz
    mkfs.vfat -F 32 -n "$label" "$w/img"

    # Copy tarball to raw image
    ls -1a "$w/root" | (
      exec 2>&1
      while read f
      do
	([ "$f" = "." ] || [ "$f" = ".." ]) && continue
	mcopy -i "$w/img" -v -b -s -m "$w/root/$f" ::
      done
    ) | stline 'Finished writing to img'

    case "$oformat" in
    raw)
      ln "$w/img" "$img.img"
      ;;
    qcow2)
      rm -vf "$img.qcow2"
      qemu-img convert -p -f raw "$w/img" -O "$oformat" $compress "$img.qcow2"
      ;;
    *)
      die 75 "Unsupported output format $oformat"
      ;;
    esac
  ) || rc=$?
  rm -rf "$w"
  return $rc
}

prep() {
  local imgsz= oformat="qcow2" label="ALB$(printf "%03d" $(expr $$ % 1000))" compress=
  while [ $# -gt 0 ]
  do
    case "$1" in
    --sz=*) imgsz=${1#--sz=} ;;
    --qcow2) oformat=qcow2 ;;
    --compress|-c) compress=-c ;;
    --raw) oformat=raw ;;
    --volume=*) label=${1#--volume=} ;;
    *) break ;;
    esac
    shift
  done
  [ $# -ne 1 ] && die 19 "Usage: $0 prep [options] src"
  [ -n "$compress" ] && [ "$oformat" != qcow2 ] && \
      die 41 "Compression is only supported in qcow2 format"

  local img="$1"

  case "$img" in
  alpine-rpi-*-aarch64.tar.gz)
    prep_alpine "$imgsz" "$oformat" "$label" "$compress" "$img"
    ;;
  *)
    prep_generic  "$imgsz" "$oformat" "$label" "$compress" "$img"
    ;;
  esac
}

is_rawfs() {
  local imgfmt=$(img_format "$1") probe rc=0 cleanup=false
  case "$imgfmt" in
  qcow2)
    probe=$(mktemp)
    if ! qemu-img dd -f "$imgfmt" -O raw bs=512 count=8192 if="$1" of="$probe" ; then
      rm -fv "$probe"
      die 93 "$1: unable to extract probe"
    fi
    cleanup=true
    ;;
  raw)
    probe="$1"
    ;;
  *)
    die 20 "$1: unrecognized image format"
    ;;
  esac

  if blkid=$(blkid -o export "$probe") ; then
    local type=$(eval "$blkid ; echo \${TYPE:-none}")

    if [ "$type" = "vfat" ]; then
      set - return 0
    else
      set - return 1
    fi
  else
    set - die 7 "$1: unrecognized image bootsector signature"
  fi
  $cleanup && rm -f "$probe"
  "$@"
}

format() {
  local resize=""

  while [ $# -gt 0 ]
  do
    case "$1" in
    --resize=*) resize=${1#--resize=} ;;
    *) break ;;
    esac
    shift
  done

  [ $# -ne 2 ] && die 51 "Usage: $0 format [options] base-img sd-img"

  local base="$1" sd="$2" basefmt=$(img_format "$1")

  if is_rawfs "$base" ; then
    if [ -n "$resize" ] ; then
      # We can-not thin provision
      local rc=0 w=$(mktemp -d -p "$(dirname "$sd")" .fmt.XXXXXXXXXX)
      (
	src="$base"
	if [ "$basefmt" != raw ] ; then
	  src="$w/srcimg"
	  qemu-img convert -p -f "$basefmt" -O raw "$base" "$src"
	fi

	mkdir -p "$w/contents"
	runst mcopy -i "$src" -s -v -b "::." "$w/contents"

	blkid=$(blkid -o export "$src")
	label=$(eval "$blkid ; echo \${LABEL:-}")
	[ -n "$label" ] && label="-n $label"

	qemu-img create -f raw "$w/dst.img" $resize
	mkfs.vfat -F 32 $label "$w/dst.img"

	# Copy tarball to raw image
	ls -1a "$w/contents" | (
	  exec 2>&1
	  while read f
	  do
	    ([ "$f" = "." ] || [ "$f" = ".." ]) && continue
	    mcopy -i "$w/dst.img" -v -b -s -m "$w/contents/$f" ::
	  done
	) | stline 'Finished writing to img'
	qemu-img convert -p -f raw -O qcow2 "$w/dst.img" "$sd"
      ) || rc=$?
      rm -rf $w
      return $rc
    fi
  fi

  # Thin-provisioned
  qemu-img create -f qcow2 -b "$base" -F "$basefmt" "$sd" $resize
}

run() {
  local vfb=false vnet=true portfwd="" model=raspi3b ttycon=true

  while [ $# -gt 0 ]
  do
    case "$1" in
      --vfb-only) vfb=true ; ttycon=false ;;
      --vfb) vfb=true ;;
      --no-vfb) vfb=false ; ttycon=true ;;
      --ttycon) ttycon=true ;;
      --no-ttycon) ttycon=false ;;
      --vnet) vnet=true ;;
      --no-vnet) vnet=false ;;
      --portfwd) portfwd=tcp::5555-:22 ; vnet=true ;;
      --portfwd=*) portfwd=${1#--portfwd=} ; vnet=true ;;
      --no-portfwd) portfwd="" ;;
      --raspi3b) model=raspi3b ;;
      # --raspi3ap) model=raspi3ap ;; # didn't work
      # --raspi0) model=raspi0 ;; # didn't work
      # --raspi1ap) model=raspi1ap ;; # didn't work
      # --raspi2b) model=raspi2b ;; # boots but fails!
      *) break
    esac
    shift
  done

  [ $# -ne 1 ] && die 51 "Usage: $0 run [options] sd-img"

  local sd="$1" sdfmt=$(img_format "$1")
  [ -z "$sdfmt" ] && die 14 "$sd: unknown image format"

  case "$model" in
  raspi3b)
    sysarch=aarch64 ; cpu=cortex-a53 ; dtb=bcm2710-rpi-3-b.dtb ; mem=1G ; smp=4
    defkernel=kernel8.img ; ini="pi3"
    ;;
  raspi3ap)
    sysarch=aarch64 ; cpu=cortex-a53 ; dtb=bcm2837-rpi-3-a-plus.dtb ; mem=512M ; smp=4
    defkernel=kernel8.img ; ini="pi3+"
    ;;
  raspi2b)
    sysarch=arm ; cpu=cortex-a7 ; dtb=bcm2710-rpi-2-b.dtb ; mem=1G ; smp=4
    defkernel=kernel7.img ; ini="pi02"
    ;;
  raspi0)
    sysarch=arm ; cpu=arm1176 ; dtb=bcm2708-rpi-zero.dtb ; mem=512M ; smp=1
    defkernel=kernel.img ; ini=""
    ;;
  raspi1ap)
    sysarch=arm ; cpu=arm1176 ; dtb=bcm2835-rpi-a-plus.dtb ; mem=512M ; smp=1
    defkernel=kernel.img ; ini=""
    ;;
  *)
    die 62 "$model: Unsupported model type" ;;
  esac

  local usbenb="" xcmdline
  ( $vfb || $vnet ) && usbenb=-usb

  $vfb || ttycon=true
  if $ttycon ; then
    xcmdline="console=ttyAMA0,115200"
  else
    xcmdline=""
  fi
  if $vfb ; then
    console="-device usb-mouse -device usb-kbd"
    $ttycon && console="$console -serial stdio"
  else
    console="-nographic"
  fi

  if $vnet ; then
    vnet="-device usb-net,netdev=net0 -netdev user,id=net0"
    [ -n "$portfwd" ] && vnet="$vnet,hostfwd=$portfwd"
  else
    vnet=""
  fi
  local rc=0 w=$(mktemp -d -p "$(dirname "$sd")" .qr.XXXXXXXXXX)
  (
    # Configure from media...

    # Extract boot partition image
    if is_rawfs "$sd" ; then
      if [ "$sdfmt" = "raw" ] ; then
        sdimg="$sd"
      else
        sdimg="$w/img"
	echo 'Decoding boot filesytem: '
	qemu-img convert -p -f $sdfmt "$sd" -O raw "$sdimg"
      fi
    else
      sdimg="$w/part"
      echo -n 'Reading bootsector: '
      qemu-img dd -f "$sdfmt" -O raw bs=512 count=8192 if="$sd" of="$sdimg"
      ls -sh "$sdimg"
      js=$(sfdisk -J "$sdimg")
      bs=$(echo "$js" | jq -r '.partitiontable.sectorsize // ""')
      skip=$(echo "$js" | jq -r '.partitiontable.partitions[0].start // ""')
      count=$(echo "$js" | jq -r '.partitiontable.partitions[0].size // ""')
      ([ -z "$bs" ] || [ -z "$skip" ] || [ -z "$count" ]) && die 72 "$sd: Error reading partion table"
      echo -n "Extracting boot partition: "
      qemu-img dd -f "$sdfmt" -O raw bs=$bs skip=$skip count=$count if="$sd" of="$sdimg"
      ls -sh "$sdimg"
    fi

    # Copy needed files
    for i in "$dtb" config.txt cmdline.txt
    do
      j=$(basename "$i")
      mcopy -i "$sdimg" -v -m "::$i" "$w/$i" || :
    done

    # Modify the command line to include console settings
    if [ -f "$w/cmdline.txt" ] ; then
      cmdline=$(cat "$w/cmdline.txt")
    else
      cmdline=""
    fi
    #if [ -n "$xcmdline" ] ; then
    #  set -x
    #  cmdline=$(echo " $cmdline" | sed -e 's/[ \t]console=[^ \t]*//' -e 's/^[ \t]//' -e 's/[ \t]$//')
    #  cmdline="$cmdline $xcmdline"
    #  set +x
    #fi
    [ -n "$xcmdline" ] && cmdline="$cmdline $xcmdline"

    kernel="$defkernel"
    initrd=""
    if [ -f "$w/config.txt" ] ; then
      config=$((echo '[all]' ; tr ' ' = < "$w/config.txt") | sed -e 's/#.*$//'  | jc --ini)
      for sec in "all" $ini
      do
	k=$(echo "$config" | jq -r ".${sec}.kernel // \"\"")
	[ -n "$k" ] && kernel="$k"
	rd=$(echo "$config" | jq -r ".${sec}.initramfs // \"\"")
	[ -n "$rd" ] && initrd="$rd"
      done
      if [ -n "$kernel$initrd" ] ; then
        for i in $kernel $initrd
	do
	  j=$(basename "$i")
	  mcopy -i "$sdimg" -v -m "::$i" "$w/$j"
	done
      fi
      [ -n "$initrd" ] && initrd="-initrd $w/$(basename "$initrd")"
      [ -n "$kernel" ] && kernel="-kernel $w/$(basename "$kernel")"
    fi

    if [ -f "$w/$dtb" ] ; then
      dtb="-dtb $w/$dtb"
    else
      dtb=""
    fi

    qemu-img info "$sd"
    set -x
    qemu-system-$sysarch \
       -machine $model -cpu $cpu -m $mem -smp $smp $dtb \
       $kernel $initrd -append "$cmdline" \
       -sd "$sd" \
       $usbenb $vnet $console
  ) || rc=$?
  rm -rf "$w"
  return $rc
}

usage() {
  O=$(basename "$0")
  cat <<-_EOF_
	Usasge: $0 {cmd} [options]

	Commands:

	- $O prep [options] tarball
	  Prepares a base image file for use.
	  Options:
	  * --sz=value : image base size
	  * --qcow2 : use qcow2 format (default)
	  * --compress|-c : compress the base image
	  * --raw : use raw format
	  * --volume : volume label, if not specified a random value is used

	- $O format [options] {base-img} {working-img}
	  Prepares a working image based on base image.
	  Options:
	  * --resize=value : create a working image of different size as base
	  * base-img : base image to use
	  * working-img : working image to use

	- $O run [options] work-image
	  Runs a working image
	  Options:
	  * --vfb-only : use virtual console (disables serial console)
	  * --vfb : enable virtual console
	  * --no-vfb : disable virtual console
	  * --ttycon : enable serial console
	  * --no-ttycon : disable serial console
	  * --vnet : enable virtual networking
	  * --no-vnet : disable virtual networking
	  * --portfwd : enable networking and port forward 5555 to 22
	  * --portfwd=rule : enable networking and specify a prot forwarding rule
	      Example rule: tcp::5555-:22
	  * --no-portfwd : disable port forwarding
	  * --raspi3b:  model=raspi3b, only working option
	  The default is running headless (only serial console) with networking enabled.

	_EOF_
  exit
}

[ $# -eq 0 ] && usage

case "$1" in
  prep) shift; prep "$@" ;;
  format) shift ; format "$@" ;;
  run) shift; run "$@" ;;
  *) usage ;;
esac



