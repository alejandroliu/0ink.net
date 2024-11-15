---
title: Replacing failed drives in a md array
date: "2024-11-13"
author: alex
---
![Broken HD]({static}/images/2025/brokenhd.png)


In a Linux softraid, you may have to replace failed drives.  As usual,
backups are still needed, but hardware failures can be covered by
RAID levels.

1. Check the array status with `cat /proc/mdstat`:
   ```bash   
   xm3:~# cat /proc/mdstat
   Personalities : [raid1] 
   md0 : active raid1 sdb[0] sdc[2]
         67042304 blocks super 1.2 [2/2] [UU]

   unused devices: <none>
   ```
2. Check the serial number of your drives to make sure you 
   are replacing the right one: `lsblk -do +VENDOR,MODEL,SERIAL`:
   ```bash
   NAME  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS VENDOR MODEL                 SERIAL
   loop0   7:0    0 108.1M  1 loop /.modloop                
   sda   253:0    0   232G  0 disk             ATA    WDC_WD2500AVVS-73M8B0 WD-WCAV94350152
   sdb   253:16   0   232G  0 disk             ATA    WDC_WD2500AVVS-73M8B0 WD-WCAV94350152
   sdc   253:32   0   232G  0 disk             ATA    WDC_WD2500AVVS-73M8B0 WD-WCAV94350152
   ```
3. Remove the faulty drive
   - Hot plugging, you can do this while the system is running, if your hardware
     supports it.
     - Remove the drive from the system.
     - Run:
       ```bash
       mdadm --manage /dev/md0 --remove failed
       ```
       Note that `failed` worked for me.  Other examles mentioned `detached`.
   - Warm plugging, some hardware requires you to enter some commands:
     - mark drive as faulty
       ```bash
       mdadm --manage /dev/md0 --fail /dev/sdc`
       ```
     - remove drive from array
       ```bash
       mdadm --manage /dev/md0 --remove /dev/sdc
       ```
     - remove the drive from the kernel
   	   ```bash
       echo 1 > /sys/block/sdc/device/delete
       ```
   - This is how mdstat looks like after:
     ```bash
     xm3:~# cat /proc/mdstat 
     Personalities : [raid1] 
     md0 : active raid1 vdb[0]
           67042304 blocks super 1.2 [2/1] [U_]
           
      unused devices: <none>

     ```
     When removing the physical drive, if possible, unplug the power cable
     first, data cable next.
5. Insert the new drive.  When possible, plug the data cable first, power cable next.
   Wait 10-15 seconds
6. Run
   ```bash
   for file in /sys/class/scsi_host/*/scan; do
     echo "- - -" > $file;
   done;
   ```
   This will re-scan the SATA buses.  This is not always needed.
8. Add the new drive to the array:
   ```bash
   mdadm --add /dev/md0 /dev/sdc
   ```
9. Check that the configuration updated correctly:
   ```bash
   xm3:~# mdadm --detail /dev/md0
   /dev/md0:
              Version : 1.2
        Creation Time : Tue Nov  5 14:44:26 2024
           Raid Level : raid1
           Array Size : 67042304 (63.94 GiB 68.65 GB)
        Used Dev Size : 67042304 (63.94 GiB 68.65 GB)
         Raid Devices : 2
        Total Devices : 2
          Persistence : Superblock is persistent

          Update Time : Wed Nov 13 14:03:42 2024
                State : clean, degraded, recovering 
       Active Devices : 1
      Working Devices : 2
       Failed Devices : 0
        Spare Devices : 1

   Consistency Policy : resync

       Rebuild Status : 0% complete

                 Name : xm3.virtual:0  (local to host xm3.virtual)
                 UUID : 95d17a6b:bee76241:c72a05d1:3cfd7d62
               Events : 28

       Number   Major   Minor   RaidDevice State
          0     253       16        0      active sync   /dev/sdb
          2     253       32        1      spare rebuilding   /dev/sdc
   ```
   You can monitor the re-build process with:
   ```bash
   # watch cat /proc/mdstat
   Personalities : [raid1] 
   md0 : active raid1 vdc[2] vdb[0]
         67042304 blocks super 1.2 [2/1] [U_]
         [=========>...........]  recovery = 45.6% (30607360/67042304) finish=3.0min speed=200060K/sec
      
   unused devices: <none>
   ```

You should check the output of `dmesg`:

```text
[  703.836264] md/raid1:md0: Disk failure on sdc, disabling device.
[  703.836264] md/raid1:md0: Operation continuing on 1 devices.
[ 1789.815521] md: recovery of RAID array md0

```

Simlarly, you should use:

```bash
smartctl -a /dev/sdc
```

To check the health status of the drive.


In here I am using raw drives (without partitioning).  If you are using partitions
make sure to run `fdisk` when appropriate.

If you have `smartmontools` installed and running, we need to reset the daemon so it
doesn't keep warning about the drive we removed.
