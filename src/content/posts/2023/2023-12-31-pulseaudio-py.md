---
title: Pulse Audio control in python
tags: desktop
---
I have been using a [shell script][old] to toggle pulse audio sinks for some time.  It worked well enough for
switching output among several profiles on a single audio card.  I recently upgraded
my set-up to new hardware.  This hardware for some reason, reported the analog stereo output and
the digital HDMI output as different sound cards.  So my patoggle script did not work well enough
anymore.

Since parsing the output of the `pacmd` in shell script was becoming a pain, I decided to re-write
the toggling script in `python`.  The new script is [here][new].

This script depends of two packages:

- [pulsectl][pypulse] : used to control pulse audio
- [notify2][pynotify] : used to send desktop notifications

It can be used to control volume and switch audio output.


TODO: make it a GUI app

- void: python3-xcffib
- pip: system_hotkey

  [old]: https://github.com/alejandroliu/0ink.net/blob/master/snippets/pa-hints/patoggle
  [new]: https://github.com/alejandroliu/0ink.net/blob/master/snippets/pa-hints/patoggle.py
  [pypulse]: https://pypi.org/project/pulsectl/
  [pynotify]: https://pypi.org/project/notify2/
  [syshotkey]: https://pypi.org/project/system_hotkey/


