#!/bin/sh
#
# Create REFIND image
#
set -euf -o pipefail


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

make_payload() {
  local zip="$1" t="$2"

  echo "Unzip \"$zip\" to \"$t\"" 1>&2
  unzip -q -d "$t" "$zip"
  local i=$(find "$t" -mindepth 1 -maxdepth 1)
  mv $(find "$t" -mindepth 2 -maxdepth 2) "$t"
  rm -rf $i
  mkdir -p "$t/EFI"
  echo "Copying to EFI directory" 1>&2
  cp -a "$t/refind" "$t/EFI/refind"
  echo "Copying to EFI BOOT directory" 1>&2
  cp -a "$t/refind" "$t/EFI/BOOT"
  mkdir -p "$t/EFI/BOOT"
  echo "Creating backup boot entry" 1>&2
  cp -a "$t/EFI/BOOT/refind_x64.efi" "$t/EFI/BOOT/bootx64.efi"
}

prep_image() {
  #
  # Create image file
  #
  local img="$1" img_sz="$2" label="$3"

  fallocate -l "$img_sz" "$img"

  # Create partitions
  sfdisk "$img" <<-_EOF_
	label: gpt
	;;U;*
	_EOF_

  local part_data=$(
    t=$(mktemp -d) ; (
      ln -s "$(readlink -f "$img")" "$t/PART"
      sfdisk -d "$t/PART" | tr -d , | sed -e 's/= */=/g'
    ) || rc=$?
    rm -rf "$t"
    exit ${rc:-0}
  )
  local \
    sector_size=$(echo "$part_data" | awk '$1 == "sector-size:" { print $2 }')
    part_opts=$(echo "$part_data" | grep '/PART1 :' | cut -d: -f2-)
  local \
    part_start=$(check_opt start $part_opts) \
    part_size=$(check_opt size $part_opts)
  local offset=$(expr $part_start '*' $sector_size)

  # Format partition
  mkfs.vfat \
	-F 32 \
	-n "$label" \
	-S $sector_size --offset $part_start \
	-v "$img"  $(expr $part_size '*' $sector_size / 1024)

  mtools_img="$img@@$offset"
}

main() {
  if [ $# -eq 0 ] ; then
    cat 1>&2 <<-_EOF_
	Usage: $0 [refind-zip] [img] [size]
	_EOF_
    exit 1
  fi
  local zip="$1" img="$2" sz="$3"
  local label="$(printf "EFI%4d" $(expr $RANDOM % 10000))"
  local t=$(mktemp -d) rc=0
  (
    prep_image "$img" "$sz" "$label"
    echo $mtools_img
    make_payload "$zip" "$t"
    echo "Copy files to image" 1>&2
    find "$t" -maxdepth 1 -mindepth 1 | (while read src
    do
      mcopy -i "$mtools_img" -s -p -Q -n -m "$src" "::"
    done)
  ) || rc=$?
  rm -rf "$t"
}

main "$@"


