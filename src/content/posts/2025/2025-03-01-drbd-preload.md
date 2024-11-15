---
title: DRBD Preload
date: "2024-10-21"
author: alex
---
![hd]({static}/images/2025/hd.png)


This is a continuation to [[2024-11-15-vm-disk-repl.md|VM disk replication]].

One of the steps needed for [[2024-11-15-vm-disk-repl.md|VM disk replication]]
is the need to pre-load the replicated volume.

For the project I wrote, we had two mechanisms:

- Copy from an attached virtual disk image
- Download from an image server

Copying from an attached virtual disk is straightforward use of the `dd` command.

Downloading from an image server was slightly triciker as it needed to:

- Resume downloads (because the large image sizes)
- Images should be stored as compressed qcow2 files.
- Use gzip on the fly so as to compress large empty disk volume areas.

This was accomplished through a script that would convert qcow2 files into raw:

```python

#!/usr/bin/env python3
#
# Stream qemu image as a raw image
#
from argparse import ArgumentParser
import nbd  # Requires python3-libnbd
import sys
import subprocess

def mycli():
  '''Create an ArgumentParser

  :returns ArgumentParser:
  '''
  cli = ArgumentParser(
    description = 'Stream a qemu image in raw format'
  )
  cli.add_argument('-c','--compress',dest='gzip',help='Enable gzip compression', action='store_true')
  cli.add_argument('--blocksize',help='Read block size',type=int, default=32*1024*1024)
  cli.add_argument('file',help='Disk image')
  cli.add_argument('offset',help='Byte offset to skip',nargs='?',type=int,default=0)
  cli.add_argument('count',help='Byte count to send',nargs='?',type=int)
  return cli


if __name__ == '__main__':
  cli = mycli()
  args = cli.parse_args()

  n = nbd.NBD()
  cmd = ['qemu-nbd', '--read-only', '--persistent', args.file]
  n.connect_systemd_socket_activation(cmd)

  if args.gzip:
    gzip = subprocess.Popen(['gzip'], stdin=subprocess.PIPE)
    fp = gzip.stdin
  else:
    fp = sys.stdout.buffer

  offset = args.offset
  size = n.get_size()
  if not args.count is None and offset + args.count < size:
    size = offset + args.count
    
  while offset < size:
    c = min(args.blocksize, size-offset)
    b = n.pread(c, offset)
    fp.write(b)
    offset += c

  n.shutdown()
    


```

And some bash script to retrieve the data:

```bash
comma() {
  echo "$1" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'                                                              
}

preload_in_guest() {
   [ -z "$preload_url" ] && return
   ( echo "$preload_url" | grep '^https*://') || return 0

   # We do this stupid process because we would time out for large
   # downloads
   cksz=$(expr 32 '*' 1024 '*' 1024) # 32M chunks

   imgsz=$(wget -nv -O- "${preload_url}?chonky=size")
   if ! ( echo "$imgsz" | grep -q '^[0-9][0-9]*$' ) ; then
	 echo "Unable to determine image size"
	 exit
   fi

   # OK, break it into chunks
   count=$(expr $imgsz / $cksz)
   if [ $(expr $imgsz - $(expr $count \* $cksz)) -gt 0 ] ; then
	 count=$(expr $count + 1)
   fi
   echo "WILL DOWNLOAD IMAGE $(comma $imgsz)b IN $(comma $count) CHUNKS"

   offset=0
   seek=0
   while [ $seek -lt $count ]
   do
	 echo "Reading chunk: $(comma $seek) of $(comma $count) ( $(expr ${seek}00 / $count)% )"
	 if ! (wget -nv -O- "${preload_url}?chonky=$offset,$cksz" \
		| gunzip \
		| dd of=/dev/drbd0 bs=$cksz seek=$seek) ; then
	   echo "Error retrieving chunk: $seek"
	   exit 1
	 fi
	 seek=$(expr $seek + 1)
	 offset=$(expr $offset + $cksz)
   done
}
```

On the server size, a PHP script is used that gets `chonky` from the query parameters and 
uses the value formatted as `offset,size` to call the python script.




