---
title: Raspberry Pi emulation with Qemu
---
The idea here is that we use a Desktop PC for developing/debugging
Raspberry Pi set-ups using [qemu][qemu] for emulating Rasperrby Pi.

[qemu][qemu] currently supports the following configurations:

- Raspberry Pi Zero and 1A+ (armhf)
- Raspberry Pi 2B (armv7)
- Raspberry Pi 3A+ (aarch64)
- Raspberry Pi 3B (aarch64)
  - This is the version I am targetting in this article.  I already recycled all
    my older boards.
  - Actually I tried emulating the other configurations but they did not work.
    Either they failed to boot, or the graphic display wouldn't work.
  - So `raspi3b` with 64-bit run-time is the only configuration I was able
    to succesfully boot.
- **NOTE that Raspberry Pi 4 is not supported at the moment.**

So, unfortunately the state of things is far from perfect.

# Missing display bug

During my tests on the `raspi3b` configuration, I was not able to get a working
console.  This has to do with this
[commit](https://github.com/raspberrypi/linux/commit/6513403f73e9bdf842597d10cb0b4775ae74d165),
which disables the Frame Buffer driver because [qemu][qemu] doesn't seem to
report the display properly.  This causes the error to show up on the kernel log:

```
bcm2708_fb soc:fb: Unable to determine number of FBs. Disabling driver.
```

Before the commit, the kernel would assume that there was always __one__ display.
On the other hand, this only affects use-cases that require display.  For headless
development, using the serial port works just fine.

For [Alpine Linux][al], the last working Frame Buffer version seems to be
`3.16.3-aarch64`.  The display did not work for `3.17.0-aarch64`.  The 32 bit
`3.16.3` would display the `Disabling driver.` message but I wasn't able to
boot further than that.

# Emulated hardware

According to the [qemu documentation][qemu-raspi], the following is impleted:

- ARM1176JZF-S, Cortex-A7 or Cortex-A53 CPU.  I only tested the Cortex-A53 CPU
  for the `raspi3b` configuration.
- Interrupt controller
- DMA controller
- Clock and reset controller (CPRMAN)
- System Timer
- GPIO controller
- Serial ports (BCM2835 AUX - 16550 based - and PL011)
- Random Number Generator (RNG)
- Frame Buffer : However the Linux kernel does not seem to find it.
- USB host (USBH)
- GPIO controller
- SD/MMC host controller
- SoC thermal sensor
- USB2 host controller (DWC2 and MPHI)
- MailBox controller (MBOX)
- VideoCore firmware (property)

As you can see, no network interface is implemented, so you must use a USB network.

# Getting started

The basic command line I am using is:

```
  qemu-system-aarch64 \
     -machine raspi3b -cpu cortex-a53 -m 1G -smp 4 -dtb bcm2710-rpi-3-b-plus.dtb \
     -kernel $linux_kernel -initrd $linux_initrd -append "$cmdline" \
     -sd $sd_image \
     -serial stdio \
     -usb \
     -device usb-mouse -device usb-kbd \
	 -device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22
```

Command explanation:

- `qemu-system-aarch64` : emulate a 64-bit ARM system
- `-machine raspi3b -cpu cortex-a53 -m 1G -smp 4 -dtb bcm2710-rpi-3-b-plus.dtb` :
  Matches the Raspberry Pi model 3B configuration.  The `dtb` is a file from the
  Raspberry Pi boot partition that is normally loaded by the Firmware.
- `-kernel $linux_kernel -initrd $linux_initrd -append "$cmdline"` : 
  Linux related boot configuration.  You must provide a kernel and optional initrd
  files.  Usually you would extract them from your `sdcard` image.  The append
  is used for the kernel command line.  If you want a serial console make sure
  you include:
  - `console=ttyAMA0,115200`
- `sd $sd_image` : Image for the `sdcard` storage
- `-usb` : Enable USB bus.  Needed for the emulated console mouse/keyboard and usb
  network.
- `-serial stdio` : enable a serial console (if you are using the emulated
  framebuffer.  Note that `Ctrl+C` are not caught and would kill the emulation.
- `-device usb-mouse -device usb-kbd` : these are used with the virtual framebuffer
  for providing keyboard and mouse.
- `-device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22` :
  Enable virtual networking using [slirp][slirp].  

If you wish to run a headless (only serial console) configuration, you should
remove the `-serial stdio -device usb-mouse -device usb-kbd` options and
just use:

- `-nographic`

This would automatically enable `-serial stdio` and remove the framebuffer.  In
this configuration `Ctrl-C` is handled properly.

# Tested OS

I tested the following images, with these results:


| Operating System | Status |
|----|-----|
| [2020-08-20-raspios-buster-arm64-lite.zip](https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2020-08-24/) | fully working |
| [2022-09-22-raspios-bullseye-arm64-lite.img.xz](https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-09-26/) | Only works *headless*.  Default user is not set properly, so the image needs to be modified to inject login credentials |
| [alpine-rpi-3.16.3-aarch64.tar.gz](https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/aarch64/) | fully working |
| [alpine-rpi-3.17.0-aarch64.tar.gz](https://dl-cdn.alpinelinux.org/alpine/v3.17/releases/aarch64/) | Only works *headless* |

# raspi-emu

For convenicne, I wrote the `raspi-emu` script:

- [rasi-emu](${SNIPPETS}/raspi-emu)

This can be used to prepare images and run emulation sessions.

Usage:

## Preparing base image

```
raspi-emu prep [options] src
```
Prepares the downloaded image so it can be used as a [qemu][qemu] thin-provisioned
image.

Options:

- `--sz=size` : Set the base image to the given `size`.
- `-c` | `--compress` : For `qcow2` images, create a compressed image.
- `--qcow2` : Create a `qcow2` format image.  This is the default.
- `--raw` : Create a `raw` image.
- `--label=name` : When creating [AlpineLinux][al] images, use `name` as the
  volume name.

## Formatting SDCARD image

```
raspi-emu format [options] base dest
```
Create an SDCARD image to be used for [qemu][qemu] emulation.  It will
create a thin-provisioned image when possible.

Options:

- `--reize=size` : Set the SDCARD image to the given size.

## Running Emulation

```
raspi-emu run [options] sdimg
```

Will boot [qemu][qemu] emulation with the specified SDCARD image.  Configuration
when possible is read from the boot partition of the SDCARD.

Options:

- `--vfb-only` : Enable the virtual framebuffer and disables the serial console.
- `--vfb` :  Enables the virtual framebuffer.  The serial console is kept enabled.
- `--no-vfb` : Disables virtual framebuffer.  This is the default.
- `--ttycon` : Enables the serial console for Linux logins.  (Default)
- `--no-ttycon` : Disables the serial console for Linux logins.
- `--vnet` : Enable virtual network.  (Default)
- `--no-vnet` : Disables hte virtual network.
- `--portfwd` : Enables virtual network.  Forwards port 5555 on host to port 22 on VM.
- `--portfwd=rule` : Adds the given port forwarding rule.
- `--no-portfwd` : Dsiables port forwarding.  (Default)
- `--raspi3b` : Emulate a Raspberry Pi Model 3B.  (Default)

The default is running headless (only serial console) with networking enabled.

[al]: https://alpinelinux.org/
[qemu]: https://www.qemu.org/
[qemu-raspi]: https://www.qemu.org/docs/master/system/arm/raspi.html
[slirp]: https://en.wikipedia.org/wiki/Slirp
