---
title: Retropie
tags: backup, boot, git, power, sudo
---

- DVD player
- Bluetooth receiver 
- keyboard 

- good keyboard bindings
- how to exit games
- convert probox into binding keys
- where are key codes saved


* * *

- Write image:
   - gunzip < retropie-4.3-rpi2_rpi3.img.gz | sudo dd of=/dev/sde bs=4M
- Configure config.txt
   - hdmi_force_hotplug=1
   - hdmi_drive=2
- Boot and configure keyboard
  - D-Pad => D-Pad
  - start : mike (F5)
  - select : menu key
  - A :  OK (enter)
  - B : back
  - X : vol-
  - Y : vol+
  ... skip all ...
  - HotKey : power
- Configure SSH
  - sudo raspi-config
      - Interfacing Options
      - Enable SSH
- Install Kodi
  - ?



* * *

- NFS
  - nfs-common should be installed.
  - sudo vi /etc/default/nfs-common
  - activate statd
  - Add systemctl start rpcbind|nfs-common to /etc/rc.local
  - Doing systemctl enable resulted in a messed up system...
  - sudo apt-get install autofs
  - Enable /net hosts from /etc/auto.master ... pointing to /etc/auto.net
     - alvm1-xvdb1d -> /net/alvm1/media/xvdb1/d
     - alvm1-xvdb1m -> /net/alvm1/media/xvdb1/m
     - alvm1-xvdb1p -> /net/alvm1/media/xvdb1/p
     - alvm1-xvdc1p -> /net/alvm1/media/xvdc1/p
     - alvm1-xvdd1p -> /net/alvm1/media/xvdd1/p
     - ow1-v1 -> /net/ow1/data/v1
     - vs1-xvdb1 -> /net/vs1/media/xvdb1
- [RTC](https://afterthoughtsoftware.com/products/rasclock)
  - sudo raspi-config
    - Interfacing options
    - I2C
  - Edit /boot/config.txt
    - dtoverlay=i2c-rtc,pcf2127
- [Power control:mausberry](https://mausberry-circuits.myshopify.com/pages/setup)
    - git clone https://github.com/t-richards/mausberry-switch.git
    - autoreconf -i -f
    - ./configure
    - make
    - sudo make install
    - Add also mausberry-switch & to /etc/rc.local
- [CEC control](https://github.com/dillbyrne/es-cec-input)
    - sudo apt-get install cec-utils
    - sudo apt-get install python-pip
    - sudo pip install python-uinput
    - git clone https://github.com/dillbyrne/es-cec-input.git
- input
  - [uinput-mapper](https://github.com/MerlijnWajer/uinput-mapper)
  - [redirection HID using uinput-mapper](http://blog.pi3g.com/2014/03/uinput-mapper-redirecting-keyboard-and-mouse-to-any-linux-system-using-a-raspberry-pi/)
  - [forums](https://www.raspberrypi.org/forums/viewtopic.php?t=85299)
  - [python-uinput](http://tjjr.fi/sw/python-uinput/)
  - [python evdev](http://python-evdev.readthedocs.io/en/latest/tutorial.html#)
  - [pytusb](https://github.com/pyusb/pyusb)

* * *

- [mausberry setup](https://mausberry-circuits.myshopify.com/pages/setup)
- [running ROMS from a share](https://github.com/RetroPie/RetroPie-Setup/wiki/Running-ROMs-from-a-Network-Share)

* * * 

- cron backup kodi
- document cec input
- re-do keyboard bindings

