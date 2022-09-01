---
title: SupervisorUI MF
tags: application, javascript, library
---
In a previous [article][prev], I updated a [supervisorui][supui] project to work for me.

This updated version [supervisorui-redone][gh] is essentially a PHP application
which is a different approach from the original [supervisorui][supui] project
which was more of a JavaScript application with some helper functionality implemented
in PHP.

As such, I figured that I could probably fix the [supervisorui][supui] code base
eliminating the `Silex` library, but keeping most of the JavaScript framework
in place.  This resulted in my [SupervisorUI-mf][g2] dashboard.

![screenshot](https://raw.githubusercontent.com/TortugaLabs/SupervisorUI-mf/master/screenshot.png)

This maintains JavaScript framework and simply removes the `Silex` dependancy.

As before, the [Incutio XML-RPC Library](http://scripts.incutio.com/xmlrpc/) was
updated so that it works with PHP8.

In addition I added/fixed the following functionality:

- Added links to [supervisor][sup] built-in web UI.
- Added links to `restart` and `reload config` [supervisor][sup] daemons.
- Fixed the `updateServers` functionality, so that services status gets updated
  every 30 seconds without having to reload the page.  Similarly, starting/stopping
  services do not need to reload the page as with [supervisorui-redone][gh].
- Added the ability to configure port's in the server IP specifications.

So the result is an updated [supervisorui][supui] which works at least for me.

Note that I am still keeping [supervisorui-redone][gh] because it is more
static than [SupervisorUI-mf][g2] which means that [supervisorui-redone][gh]
works better with **High Latency** (high ping time) connections.

  [sup]: http://supervisord.org/index.html
  [suptools]: http://supervisord.org/plugins.html#dashboards-and-tools-for-multiple-supervisor-instances
  [supui]: https://github.com/Tabcorp/supervisorui/
  [gh]: https://github.com/TortugaLabs/supervisorui-redone
  [g2]: https://github.com/TortugaLabs/SupervisorUI-mf
  [prev]: /posts/2022/2022-08-25-supervisorui-redone.html



