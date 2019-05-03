---
title: Co-existing GLIBC binaries with Void-Linux MUSL edition
---

I am running [void-linux](https://voidlinux.org/) at home with `musl` as the standard
C library.

While most things work well, there is a number of programs that
do not and must be using `glibc` counterparts.

To enable this I followed this guide here: [Live switching Void Linux from glibc to musl](https://blog.w1r3.net/2017/09/23/live-switching-void-linux-from-glibc-to-musl.html).

To set-up:

```
mkdir -p /glibc
sudo env XBPS_ARCH=x86_64 xbps-install --repository=http://alpha.de.repo.voidlinux.org/current -r /glibc -S base-voidstrap
```

- `sudo` : yes, we need root
- `env` : Needed because we are using `sudo`.
- `XBPS_ARCH=x86_64` : architecture to use.  Since we are using musl,
  we point to the glibc version.  It should be possible to create
  a 32 bit root here.
- `--repository=http://alpha.de.repo.voidlinux.org/current` : the repository
  to use.  Feel free to replace to something closer.
- `-r /glibc` :  directory tree where the glibc executables will live
- `base-voidstrap` : unlike `base-system`, this meta-package is normally
  used for containers.

To keep this tree up to date:

```
sudo env XBPS_ARCH=x86_64 xbps-install --repository=http://alpha.de.repo.voidlinux.org/current -r /glibc -Su
```

To add software to the tree:

```
sudo env XBPS_ARCH=x86_64 xbps-install --repository=http://alpha.de.repo.voidlinux.org/current -r /glibc -S pkg
```

Once this is set-up you need a small program to kick off the `glibc` executables.  I copied this one:

<script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/void-glibc-in-musl/glibc.c?footer=minimal"></script>

To compile and install:

```
gcc -s -o glibc glibc.c
sudo cp glibc /usr/bin
sudo chown root:root /usr/bin/glibc
sudo chmod +sx /usr/bin/glibc
```

Then you can just run:

```
glibc cmd args
```

The following software I have found doesn't work well using `musl`:

- Calibre
- building buildroot (Because of compilation of `fakeroot`)

