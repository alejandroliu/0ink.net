---
title: Tunneling NFS over SSH
date: "2023-09-01"
---
This recipe is for tunneling NFS traffic over SSH.  This adds encryption
and Public Key authentication to otherwise insecure NFS traffic.

For this recipe to work, requires NFSv4.  Earlier versions were
not tested, but I expect not all the functionality to work.

# server configuration

Install packages:

- nfs-kernel-server
- ncat or netcat-openbsd

Configure `/etc/exports`.  Add a line:

```bash
/export/path 127.0.0.1(insecure,... other options...)
```

- `/export/path`: File system to export
- `127.0.0.1`: Loopback address, we only allow local connections.
- `insecure`: Normally, the NFS server only allows connections from ports
  less than 1024.  This option removes that restriction.  We need this because
  the `ssh` traffic is running as a normal user.

Additional NFS export options:

- `rw` : Allow read/write access
- `sync` : sync I/O (recommended to prevent data loss)
- `no_subtree_check` : When exporting full filesystem, this remove the subtree checks.
  This has to do with the fact that `NFS` uses `inodes`.  This check is needed to
  make sure that the `inode` is within the exported filesystem sub-tree.  However
  if you are exporting the entire filesystem, there should never be the case
  that an `inode` falls outside the `subtree`.
- `no_root_squash` : allow root access
- `mountpoint=/mount/path` : Only export if a filesystem is mounted on `/mount/path`

Obtain a public/private key.  Either use `ssh-keygen` or copy it from elsewhere.
Install `authorized_keys` on the account to be used for SSH/TCP forwarding:

```bash
command="nc -N  localhost 2049",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa ...

```

This account does not need to be `root`.  The additional settings make sure that this
key can only be used for forwarding traffic.


# client configuration

This is for [Ubuntu][ubuntu].  Other distros may need different packages
and/or approaches.

Install packages:

- nfs-common
- ncat (netcat-openbsd is not enough, ncat needs to support -e or -c)

Make sure the NFS server is in the SSH forwarder's `known_hosts` file.  Use this command
to make sure this happens:

```bash
ssh -n -i $ssh_key -T \
        -o StrictHostKeyChecking=accept-new \
        -o BatchMode=yes \
        -o ConnectTimeout=10 \
        $nfs_server
```

In this approach we are using `ncat` to implement `SSH` forwarder.  Run this
command from the `/etc/rc.local` file:

```bash
lport=4096
ssh_key=/path/to/ssh/private/key
ssh_opts="-o BatchMode=yes -o ConnectTimeout=10 -a -C"
nfs_srv=nfs-server

( ncat -l $lport -k --allow localhost -c "exec ssh -i $ssh_key $ssh_opts $nfs_srv" ) &
```

Options:

- `-a` : disable agent forwarding
- `-C` : request compression
- `-T` : disable pty

An alternative to this is to use `inetd.conf` or use [systemd](http://0pointer.de/blog/projects/inetd.html).

At this point we are ready to mount NFS filesystems:

```bash
mount -t nfs \
  -o nfsvers=4,nolock,nosuid,nodev,port=4096,sec=sys,tcp,soft,intr,fg \
  localhost:/export/nfs/path \
  /mnt
```

Options:

- `nfsvers=4` : make sure we are running NFSv4
-  `nosuid` : disable SUID executables
- `nodev` : disable device files
- `sec=sys` : traditional UNIX security modes
- `tcp` : use TCP protocol
- `soft,intr` : how we handle CTRL+C and other errors

# Caveats

- `showmount` command does not show NFSv4 information.
- I have not tried to use this with `autofs`.  `autofs` configure for NFS shares is in
  `/etc/autofs/auto.net`, but it uses `showmount` command, so it probably would not
  work out of the box.



References:

- [Common NFS mount options](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/storage_administration_guide/s1-nfs-client-config-options)
- [/etc/exports documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/deployment_guide/s1-nfs-server-config-exports)
- [ubuntu][ubuntu]
- [autofs help](https://help.ubuntu.com/community/Autofs)
- [Ubuntu NFSv4 HOWTO](https://help.ubuntu.com/community/NFSv4Howto)


  [ubuntu]: https://en.wikipedia.org/wiki/Ubuntu
