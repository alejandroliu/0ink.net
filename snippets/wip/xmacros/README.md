# Macros

## Alternative approach

- Use python's
  - uinput : for synthetic events
  - libevdev : for reading events
- This approach works independantly or Xorg, console or Wayland
- Requires elevated priviledges (unless we can use polkit)
- A daemon runs in the background reading kernel events and
  accepting clients on a UNIX socket.
- Clients connect to daemon and receive keyboard events and
  can send simulated key-presses
- Client can then read keyboard events for global hotkeys or
  recording macros.
- Client can send synthetic keyboard events to run macros.

## Possible approach

- Use pynput for input
- Replaces xbindkeys and related functionality
- emwh for window manager functions
- we launch on start-up and monitor keyboard state
- Functions
  - global hotkeys
    - debouncing
    - launch internal function
    - launch external command
  - global config and per-user config
  - Integrate macro recording/playback
  - size screen area, patch nom max windows

Hotkeys internal functions
- paste text only (??)
- show desktop
- wm control (tile, max, min, other tile positions)

***

**This doesn't work**

I tried the following:

- [pynput](https://pypi.org/project/pynput/) for recording.
  - Library that does monitoring and playback.
  - requires writting my own stuff.
  - Kinda works but not well.
    - Need to get current key statuses and reset them.  Could probably
      work better if it was its own thing instead of xbindsrc executables.
- xmacro
  - [homepage](https://xmacro.sourceforge.net/)
  - Just a couple of `cpp` files.  Compiles with `Makefile`?
  - Had to be converted from C++ to plain C.
  - Playback seems to work.
  - Recording not working right.
- ~~xnee~~ : wouldn't compile.  And it is a large code base.
  - [Home](https://xnee.wordpress.com/)
  - [Downloads](http://ftp.gnu.org/gnu/xnee/)
  - Compiles using `configure` script.
- atbswp
  - Dependancies were a bit messy.
  - [github page](https://github.com/RMPR/atbswp)
  - Python, uses [PyAutoGUI](https://pyautogui.readthedocs.io/en/latest/#) for
    playback, and [pynput](https://pypi.org/project/pynput/) for recording.
- sikulix
  - [homepage](http://sikulix.com/)
  - ??It has OpenCV image recognition??
  - (n) uses Java
  - This is more of a Selenium alternative.

# pynput

What I did, is, using the pynput library, I wrote a record and
playback scripts.

- t.sh : script to set-up things
- xbindkeysrc : hotkeys configuration to record and play macros
- xmplay : shell script entry point for playback
- xmrecord : shell script entry poing for record
- xmplay.py and xmrec.py : python scripts doing the heavy lifting.

Playback of macros doesn't seem to work reliabily.

# xmacro

Rewrote the code from C++ to plain C.  The recording works, but
it is very wonky.

Playback kinda works, but not reliabily either.

***


***

Replace pidgin.desktop with mypidgin.desktop
- Launches pidgin but monitor things so that it is minimized
