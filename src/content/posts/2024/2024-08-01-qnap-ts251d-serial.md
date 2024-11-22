---
title: Adding a serial port to a QNAP TS-251D
date: "2024-04-20"
author: alex
tags: alpine, device
---
![Connector]({static}/images/2024/3dp/img6.png)


I am using a [QNAP TS-251D][ts251d] NAS.  Because I would like to switch from [QTS][qts] to
[Alpine Linux][alpine] I though it would be useful to enable the serial port.

The [TS-251D][ts251d] has a built-in serial port that is already enabled and only needs to be
connected.  For that you need a number of parts:

* [JST 4-pin connector][amz-jst].  I selected
  [Adafruit accessoires JST PH 2mm 4-pins - 3950][amz-jst]
* [TTL to Serial port level converter][amz-cnv].  I am using
  [JZK 4 PCs 3V-5V RS232 to TTL serial port module][amz-cnv].

In addition, I am using a 3D printed bracket to hold the serial port.

Examinig the QTS environment you can see that there is indeed a `/dev/ttyS0` device (a serial
port) and it is enabled in the Kernel command line with:

```bash
console=ttyS0,115200n8
```

Simmilarly you can find in the `/etc/inittab` a line:

```bash
ttyS0::respawn:/sbin/getty -L ttyS0 115200 vt100
```

So there is a serial port available and being used for debugging.

To make it visible to the outside, you only need to connect to JST1

![Connector]({static}/images/2024/3dp/img3.png)

Pins from left to right.

1. GND
2. RX
3. VCC
4. TX

For the bracket to hold the serial port I printed this
[3D Model](https://github.com/alejandroliu/0ink.net/blob/main/src/content/images/2024/3dp/bracket.stl).

Place the Serial module on the 3D printed bracket.

![Bracket]({static}/images/2024/3dp/img1.png)

And mount it on the case:

![Case with bracket1]({static}/images/2024/3dp/img7.png)

![Case with bracket2]({static}/images/2024/3dp/img4.png)




  [ts251d]: https://www.qnap.com/en/product/ts-251d
  [qts]: https://www.qnap.com/qts/5.0/en/
  [alpine]: https://alpinelinux.org/
  [amz-jst]: https://www.amazon.nl/dp/B0CTKSDDFT
  [amz-cnv]:  https://www.amazon.nl/dp/B09L1BB6F8
  
