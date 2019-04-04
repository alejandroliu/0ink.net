
Resize virtual disk

lvexted -L +50G /dev/vg0/lv0
cat /proc/partitions
wil show dm-xx but the major/minor is the same
virsh blockresize --path /dev/vg0/lv0 --size (from /proc/partitions) vms5

