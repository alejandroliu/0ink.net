---
title: Z-Wave Associations with With Vera UI
---

I couldn't find any to the point documentation on how to do this,
so I am writing this.

The way I understand Z-Wave associations work is that once devices
are in the same Z-Wave network, a device can directly send
a command to another device without intervention of the Hub
or controller.

For this to really work the master device sending commands must
support this functionality.  This varies from device to device,
so you must look up the documentation of the master device and
find the supported associations groups.  In a nutshell, you look-up
what each association group is for, and then you add to that group
the slave devices that will receive the Z-wave commands from the
master.

So for example, a `TKB-Home TZ55D` Wall mounted dimmer/switch
with two buttons has the
following association groups:

- Group 1: Control device using the left button.
- Group 2: Control device using the right button.
- Group 3: Control device using the right button after a double tap.
- Group 4: Control device so that it follows the switch state.

So this dimmer/switch has two buttons, the left button is used for
local control.  The right button can be used to control devices
associated to groups 2 and 3.

In the Vera UI7 this is done as follows:

1. Go to the `Devices` list.
2. Locate the *master* device in the list and click it `settings`
   button.
3. Click `Device Options`.
4. Under *Associations*, enter the `Group ID` from the documentation
   as explained above, and click `Add group`.
   You may need to click `Back` and enter `Device Options` again
   for the group to be visible.
5. Once the desired `Group ID` is available, click on the `Set`
   button.
6. Click the Z-Wave devices checkbox to add them to the group.
   Leave the entry field next to the device is to enter sub-device
   ids.  This is used for multichannel devices.  For example, an
   RGBW controller may have multiple channels to control the
   different color LEDs.  Check the *slave* device documentation
   for the valid sub-channel IDs to use.



