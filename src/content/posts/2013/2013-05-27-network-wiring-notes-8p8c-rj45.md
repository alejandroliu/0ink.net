---
title: Network wiring notes - 8P8C / RJ45
tags: computer, network, power, speed
---

What you were probably looking forT568A/B (10-BASE-T and 100-BASE-TX):

With pin positions are counted from _left to right_ with the _contacts facing_ you (clip on the back) and pointing up _(cable coming out the bottom):_

|Color (568B)|Pin|Color(568A)|
|--- |--- |--- |
|Orange-white|1|Green-white|
|Orange|2|Green|
|Green-white|3|Orange-white|
|Blue|4|Blue|
|Blue-white|5|Blue-white|
|Green|6|Orange|
|Brown-white|7|Brown-white|
|Brown|8|Brown|


![wiring1]({static}/images/2013/wiring1.jpg)

Cut the outer insulation and order the wires (right), cut for equal length (not shown), and insert into plug (left)

![wiring1]({static}/images/2013/wiring2.jpg)

Check that the wires go to the end of the plug by seeing if you can see each wire at the end, preferably see its copper reflecting (left).

Then use the crimping tool (shoves the pins into the wires, and fixes the wire in the plug.

_100Mbit ethernet_ (Fast Ethernet, FE) uses only two pairs - pins 1, 2, 3, and 6, which in the standard wiring are the orange and green wire pairs.

This means you could use the other wires for different things - e.g. one link and a phone (non-conflicting if you use the stand pins for each), or some more custom combination such as two links though one wire.

_Gigabit ethernet_ uses all four pairs, so has no creative options.

On crossover cables
===================

Given the two plug colorings in 568-type wiring, cables wired with these can be:

*   A _straight cable_, 568B-568B (or the functionally equivalent 568A-568A, but in terms of colors the B-B variant seems to be used everywhere, probably to avoid confusion)
*   A _crossover cable_ (also _patch cable_) has 568A on one end and 568B on the other. (crossing is also effectively done by a switch or hub, so you can use straight cables except in cases where you don't use switches. Crossovers can be useful for direct computer-computer connections).

Gigabit ethernet doesn't need crossovers -- it decided to handle that case inside the NIC and switches rather than have you do it the cable. You use straight cables everywhere (NIC-switch-NIC and NIC-NIC).

Gigabit crossovers are rumored to exist (crossing blue and brown in addition to orange and green), but they are unnecessary.

On Loopbacks
============

Loopbacks connect a port to itself. This can be used to test whether a long cable and/or its wallplug is broken, and whether a switch/router port is broken (or perhaps dirty or corroded), both just by seeing whether the link light comes on.

Connect:

*   Pin 1 to 3
*   Pin 2 to 6
*   Pin 4 to 7 (for a gBit loopback)
*   Pin 5 to 8 (for a gBit loopback)

(If you're wiring a plug as a loopback, make sure you're not confused about which end is pin is pin 1). To create a loopback from a plug-with-cable you cut (that was wired according to 568A or 568B), this means:

    Orange-white  to  Green-white
    Orange        to  Green
    Blue          to  Brown-white  (for a gBit loopback)
    Brown         to  Blue-white   (for a gBit loopback)


gBit loopback is a limited concept:
===================================

Gigabit NICs have crosstalk detection (detects how much signal interferes onto other wires), and will likely decide that the loopback is an extreme amount of crosstalk - any may not show link. Meaning it's often only useful on NICs which let you disable crosstalk detection. Gigabit switches may behave differently (but I'm not sure what the spec says or the real-world variation is)

More notes on ethernet wiring

The wiring used on 10Mbit, 100Mbit (specifically 10-BASE-T and 100-BASE-TX) ethernet over 8P8C (informally RJ45) plugs is defined by _TIA/EIA-568-B_, which define two plug wiring alternatives, 568A and 568B. Notice the lack of dashes; 568-B is the standard they are part of, 568-A a completely different standard (yes, that naming is stupidly confusing).

Note that both 10Mbit and 100Mbit networking use only pair 2 and 3 (orange and green) in the standard (The blue pair is pair 1, orange is pair 2, green is pair 3, and brown is pair 4.)

This means that Americans or anyone else using 4P/6P-style phone connectors can use fully wired cables (most are fully wired - relatively few (cheaper) cables are only two-pair for only Ethernet) to wire their house/company and have the same sockets be usable to plug in phones, a computer (or both with a trivial splitter). Various companies can use use this to make their wiring simpler.

Gigabit ethernet
================

GBit ethernet can use cables wired 568-style, preferably rated Cat5e, or better.

Specifically, you want straight wiring and four-pair cable. Most older cables are, so can be used at gBit speeds, as 1000-BASE-T uses all four pairs instead of just two.

(If you press your own plugs, it is suggested that you keep the untwisted length as small as possible, to minimize near-end crosstalk)

Some implications:

*   you can't do the phone/networking split mentioned above
*   on-the-cheap two-pair cables will work, but only because the NICs fall back to 100mbit
*   you can mix 10/100/1000 in your network, by replacing switches (handy for partial/gradual upgrades), without having to wire about the cabling.

...as long as the cable is rated Cat5e (or better)

On cable standards (Cat5, etc.)
===============================

*   Cat5
    *   rarely seen - it has fallen out of favour and is barely sold
    *   (...but your company may still be wired with it)
    *   regularly and informally refers to Cat5a
*   Cat5a
    *   Currently still quite common
    *   100mBit, 1gBit at <100m
*   Cat6
    *   100mBit, 1gBit at <100m
    *   <55m for 10gBit (less if many are bundled)
*   Cat6a
    *   10GBit at <100m
*   Cat7 - stricter about crosstalk (pairs individually insulated)

Any cabling that is not shielded will crosstalk, meaning permissible distances are lower when many are bundled (relevant to company wiring), or be likely to get a lot of outside interference.

The Shiny Special Expensive cables sold in the sort of computer shops that only sell things that come in plastic boxes are generally not necessary, particularly not on the few-meter cables for your home LAN.

For example, Cat6 was made for 10gBit, most single computers don't have a source of data to actually use that speed, and even if they had, it's hard to get a 10gBit switch.

Companies may want Cat6 (or perhaps Cat6a) for future compatibility, to be able to use gBit now and assuming that nothing replaces copper before the next update.

Cat7 can go beyond 10gBit at short-ish distances, but chances are you won't be needing that any time soon. Only data centers might care.

Naming pendantics and telephony
===============================

When we say RJ45, we often mean something like "Ethernet wiring on an 8P8C plug."

RJ is the group of plugs that can be described by their positions and connectors, such as 8P8C in Ethernet, while RJ45 actually refers to a specific telephone wiring on the 8P-style plug (probably the most common one among several), while 8P8C refers to that plug itself and no specific wiring. Regardless, most people call the plug RJ45, regardless of wiring.

Plugs may have fewer actually present conductors than they have positions, so 8P2C, 8P4C, 8P6C, 8P8C, 6P2C, 6P4C, 6P6C, 4P2C, 4P4C all exist.

When there are less connectors than positions, they are in the middle positions; RJ-style wiring is from the middle out.

For most of us, the is interesting only in that you can plug a phone with 6P plugs into a 8P (ethernet-plus-phone) socket and have the phone work - the clip aligns the plug in the middle.

If more more than the middle two wires are used in telephone wiring, they carry either power, or a second (RJ14) or even third (RJ25) telephone line on the same wire, but consumers rarely see this type of phone wiring)}}

There are exceptions to the 'always start in the middle', but they tend to be intentionally working around RJ-style wiring.

The most common use of 6P outside of the US is probably phone wiring according to RJ11, which often use just a single pair in the middle. In the US, 8P connectors with the RJ45 phone wiring is common.
