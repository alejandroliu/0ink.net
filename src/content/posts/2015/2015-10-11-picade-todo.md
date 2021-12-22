---
title: Picade Todo
date: 2015-10-11
---

1. [key mappings](http://forums.pimoroni.com/t/picade-pcb-emulator-key-mapping/922)
   - look up and label default mappings

```
  { KEY_UP_ARROW,    UP     },
  { KEY_DOWN_ARROW,  DOWN   },
  { KEY_LEFT_ARROW,  LEFT   },
  { KEY_RIGHT_ARROW, RIGHT  },

  { KEY_LEFT_CTRL,   BTN_1  },
  { KEY_LEFT_ALT,    BTN_2  },
  { ' ',             BTN_3  },
  { KEY_LEFT_SHIFT,  BTN_4  },
  { 'z',             BTN_5  },
  { 'x',             BTN_6  },

  { 's',             START  },
  { 'c',             COIN   },
  { KEY_RETURN,      ENTER  },
  { KEY_ESC,         ESCAPE },

  /* Change these lines to set key bindings for VOL_UP and VOL_DN */
   { 'u',      VOL_UP  },
   { 'd',      VOL_DN },
```

1. Properly secure pi to case
2. Properly configure MAME
3. SSH to picade
4. Add roms to picade
3. Add a external port to plugin controllers
5. scrapping games How?
6. netplay
7. setup battery power
7. Change the art work
8. Properly install power button
9. [minecraft server](http://picraftbukkit.webs.com/pi-minecraft-server-how-to)
10. Install Java and how to run minecraft on PC
11. Add a HD for PS1 games [sata adapter](https://shop.pimoroni.com/products/sata-hard-drive-to-usb-adapter)


# Wiring...

```
GPIO --- 220Ohm --- +LED- ---> GND
```

Python

```
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
GPIO.setup(25, GPIO.OUT)
GPIO.output(25, 1)
GPIO.cleanup()

GPIO.setup(22, GPIO.IN)
GPIO.input(22) == bool
```

ASCIART

```
                            +--- 10 kOhm --- GND
                            |
                            |
                            |      _-v
GPIO -- 1 kOhm --+---+    +------ 3.3V
```

[button](https://www.arduino.cc/en/Tutorial/Button)

```
GND -- 10K Ohm --+---+ SW +--- 5V
			     |
GPIO----------------+
```

[joystic](https://www.arduino.cc/en/Tutorial/JoyStick)

