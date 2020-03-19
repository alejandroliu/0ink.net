---
title: Using XScreenSaver Hacks with mate-screensaver
---

Here we explain how to use [XScreenSaver][xscr] **EXCELLENT**
screensaver hack collection with the [MATE][mate] screensaver
applet.

- Install `xscreensaver` and `mate-screensaver`
- On my linux distribution this creates the following directories:
  - `/usr/libexec/xscreensaver`: contains the screensaver hacks executables
  - `/usr/libexec/mate-screensaver` : contains the `mate-screensaver` executables
  - `/usr/share/applications/screensavers` : containes the `dekstop` files
- Create a small script that will call the screensaver hack with the right
  arguments.  Make sure this script is in the `/usr/libexec/mate-screensaver`
  directory, as the `mate-screensaver` preferences will not accept any
  executables that are not in the right places.
- Create a desktop file to call the screensaver hack.  Verify that
  the `Exec` property contains the application with the right arguments
  and the `TryExec` only contains a path to the script that you created
  in the previous step.  The `mate-screensaver` preferences applet
  will test if the file specified in `TryExec` is indeed executable.
- Restart `mate-screensaver`.  I usually logout and log back in.

For my computers I use this script:

<script src="https://gist-it.appspot.com/https://github.com/alejandroliu/0ink.net/raw/master/snippets/mate-screensaver-hacks/installer.sh?footer=minimal"></script>

This simplifies the full process.  Just run the script (you may need to
`sudo`) with the following options:

- `$0 hacks [-e|-d]`
  - shows the list of hacks and its enabled|disabled status.
  - the `-e` option will only show enabled hacks.
  - the `-d` option will only show disabled hacks.
- `$0 enable [--all|hacks]
  - enable the specified hacks.
  - Use `--all` to enable all available hacks (excluding blacklisted hacks)
- `$0 disable [--all|hacks]
  - disable the specified hacks.
  - Use `--all` to disable all available hacks

* * *

If you like [XScreenSaver][xscr] and would like to see the same software
on Windows, you should read [this article][no-win-xscr] from the
[XScreenSaver][xscr] author.




[xscr]: https://www.jwz.org/xscreensaver/
[no-win-xscr]: https://www.jwz.org/xscreensaver/xscreensaver-windows.html
[mate]: https://mate-desktop.org/
