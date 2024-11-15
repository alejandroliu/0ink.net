---
title: VM managed disk replication
date: "2024-10-21"
author: alex
---
[toc]

![repl]({static}/images/2025/repl.png)


# Introduction

This recipe is for adding disk replication to VMs using KVM hypervisor.  The idea is to keep
VM operations independant of storage operations in non-vertically integrated support
teams.  In this scenario, VM Operators only need to manage VMs, and storage is delegated to
a storage team that manages virtualized storage delivery services, one of these being 
replicated storage service.

# High level overview


![Block diagram]({static}/images/2025/hl-erised-lo.png)


This solution is based on [Ubuntu 22.04][ubuntu-lts-22].  Note that normal
disk images can not be used as repliacted disks unless they have a *DRBD* device
signature already embedded on them.

There are two KVM hosts, for providing a High Availability cluster.  There are two VMs,
each running on the different KVM hosts.  These mirror VMs are managing the replication.

There are two additional VMs for running the applicaiton.  One *one* of these VMs should
be active.

# Deployment

- Create mirror VMs with the same configuration:
  - 2 vCPUs
  - 4096MB RAM
  - Netwoks:
    - 1 vNIC for replication (does not need to be routed)
    - 1 vNIC for iSCSI/NBD protocol (only needs to be routed to clients, i.e. KVM host or 
      client VMs)
    - 1 vNIC for management and accessing Ubuntu software repositories.
    - 1 OS disk, 1 data disk
- Primary (mirror-a):
  - Download required packages from Ubuntu repos
  - Configure DRBD and start first sync (this happens in the background)
  - Download or copy disk pre-load image
  - Set-up NBD server or iSCSI target
- Secondary (mirror-b):
  - Download required packages from Ubuntu repos
  - Configure DRBD (as secondary)
  - Set-up but *NOT* start NBD server or iSCSI target

## Required packages

- drbd-utils : Needed for DRBD
- tgt : Needed for iSCSI
- nbd-server : Used for the NBD server

## DRBD configuration

**Recommended**: Modify `/etc/hosts` to include IP address of peer VMs.

![drbd]({static}/images/2025/drbd.png)


Install DRBD drivers:

```bash
apt -y install linux-modules-extra-$(uname -r)
modprobe drbd
```

path: `/etc/drbd.conf`

```bash
     global { usage-count no; }
     common { disk { resync-rate 100M; } }
     resource r0 {
        protocol C;
        startup {
                wfc-timeout  15;
                degr-wfc-timeout 60;
        }
        net {
                cram-hmac-alg sha1;
                shared-secret "secret";
        }
        on {{vmbase}}a {
                device /dev/drbd0;
                disk /dev/sdb;
                address ${vm1_ipaddr}:7788;
                meta-disk internal;
        }
        on {{vmbase}}b {
                device /dev/drbd0;
                disk /dev/sdb;
                address ${vm2_ipaddr}:7788;
                meta-disk internal;
        }
     } 

```

Initialize DBRD device:

```bash
#!/bin/sh
#
# Do not initialize it twice!
(blkid /dev/sdb | grep 'TYPE="drbd"') && exit 0
. /root/mirdata.txt # defines $drbd_role as primary or secondary
drbdadm create-md r0
systemctl enable drbd.service
systemctl start drbd.service
#
case "$drbd_role" in
primary)
  drbdadm -- --overwrite-data-of-peer primary all
  ;;
esac
```

At this point `/dev/drbd0` can be pre-loaded with the contents of the replicated drive.

## Configure NBD server

![nas]({static}/images/2025/nas.png)


path: `/etc/nbd-server/config`

```bash
[generic]
[r0]
exportname = /dev/drbd0
# Default to port 10809
```

Start primary:

```bash
systemctl enable nbd-server
systemctl start nbd-server
```

Start secondary:

```bash
systemctl disable ndb-server
systemctl stop nbd-server     	

```

## Configure iSCSI target

![iSCSI]({static}/images/2025/iscsi.png)

path: /etc/tgt/conf.d/target1.conf

```xml
# if you set some devices, add <target>-</target> and set the same way with follows
# naming rule : [ iqn.(year)-(month).(reverse of domain name):(any name you like) ]
<target iqn.2023-10.world.srv:dlp.target01>
  # provided devicce as a iSCSI target
  backing-store /dev/drbd0
  # iSCSI Initiator's IQN you allow to connect
  # initiator-name iqn.2023-10.world.srv:node01.initiator01
</target> 

```

## Primary server

```bash
systemctl enable tgt
systemctl restart tgt     	

```

## Secondary server

```bash
systemctl disable tgt
systemctl stop tgt
```


# Client setup

![clients]({static}/images/2025/nas2.png)

The mirrored storage is exported either as NBD or iSCSI target.

VM clients can mount the storage using the facilities available for that VM's Operating
System.

For KVM volumes (to use as OS for example) these are configured in the VM XML
depending on the protocol to use.

## KVM NBD client

Firewall configuration:

```bash
sudo ufw allow out 10809/tcp
```

VM XML configuration snippet:

```xml
<disk type='network' device='disk'>
      <driver name='qemu' type='raw' cache='none'/>
      <source protocol='nbd' name='r0' >
        <host name='ip-address-of-server' port='10809'/>
      </source>
      <target dev=‘vdc' bus=‘virtio'/>
</disk>
```
Port 10809 is the default, so that setting can be omitted.

## KVM iSCSI client

For simplicity we are not using iSCSI authentication and simply uses the iqn identifiers
and potentially IP addresses to control access.

Firewall Configuration:

```bash
sudo ufw allow out 3260/tcp
```
VM XML Configuration snippets:

```xml
<disk type='network' device='disk'>
    <driver name='qemu' type='raw'/>
    <source protocol='iscsi' name='iqn.2023-10.world.srv:dlp.target01/1'>
      <host name='192.168.39.184' port='3260'/>
      <initiator>
        <iqn name='iqn.2023-10.world.srv:node01.initiator01'/>
      </initiator>
    </source>
    <target dev='sdc' bus='sata'/>
</disk>
```

# Performance Impact

![metrics]({static}/images/2025/metrics.png)


Protocol | Emulation | 512 Reads (MB/s) | 512 Writes (MB/s) | 1MB Reads (MB/s) | 1MB Writes (MB/s) 
---------|-----------|-----------------:|------------------:|-----------------:|------------------:|
iSCSI    | sata      | 174.0            | 11.5              | 316.0            | 131.0
iSCSI    | virtio    | 201.0            | 15.1              | 317.0            | 133.0
nbd      | sata      | 164.0            | 12.7              | 308.0            | 130.0
nbd      | virtio    | 210.0            | 20.0              | 347.0            | 135.0
Direct   | sata      | 162.0            | 12.7              | 317              | 339.0

- iSCSI with SATA emulation provides the most compatibility
- NBD with virtio emulation provides the highest performance.
- iSCSI with SATA has the highest per IOP overhead.
- nbd has lower protocol overhead than iSCSI
- virtio has better virtualization performance than sata emulation
- For large data transfers overhead ceases to be  relevant.

  [ubuntu-lts-22]: https://releases.ubuntu.com/jammy/



