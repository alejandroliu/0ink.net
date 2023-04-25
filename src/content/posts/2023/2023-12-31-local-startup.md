---
title: Local Startup
tags: application, config, configuration, desktop, directory, editor, linux
---
This is a method to control start-up of applications in a Linux Desktop session
that are run by a local default configuration, but can also be overriden by the user.

This is unlike the `/etc/xdg/autostart` which is mostly under the control of the 
distro packager.

Aslo unlike the `/etc/X11/profile.d` directory, this runs inside the Desktop Session.
`/etc/X11/profile.d` gets started *before* the Desktop session is available.

There is a configuration `/etc/xdg/local-startup.cfg`, which contains the local 
configuration.  It is a text file:

```
# comments start with #
#
delay 3000 # Number of seconds to wait before starting applications
application1.desktop  enable # Enable the application
application2.dekstop  disable # disable this application
```

Applications that can be auto started are defined either in `/usr/share/applications`
or in `$HOME/.local/share/applications` as `.desktop` files.

Adding a *enabled* application global config, will start the application by default.

Adding a *disabled* application to the global config, will *not* start the application
by default, but it makes it possible for the user to override this setting
in their `$HOME/.config/local-startup.cfg` file.

Files:

- [local-startup.tk](https://github.com/alejandroliu/0ink.net/blob/master/snippets/local-startup/local-startup.tk)
  : main implementation script
- [local.cfg](https://github.com/alejandroliu/0ink.net/blob/master/snippets/local-startup/local.cfg) :
  example configuration file
- [local-startup-autostart.desktop](https://github.com/alejandroliu/0ink.net/blob/master/snippets/local-startup/local-startup-autostart.desktop) :
  desktop file to run when session starts
- [local-startup-prefs.desktop](https://github.com/alejandroliu/0ink.net/blob/master/snippets/local-startup/local-startup-prefs.desktop)
  : desktop file for preferences editor
 










# Local startup

This is a way to have startup configuration that is system wide, but
still can be overriden by end-user.
