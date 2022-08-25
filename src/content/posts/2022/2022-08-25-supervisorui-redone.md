---
title: Supervisorui REDONE
tags: application, javascript, library, power, software, tools
---
Currently I am using docker containers to deploy applications.  A number of those
containers make use of [supervisord][sup] for managing processes.  While
[supervisord][sup] itself comes with a UI, it is unhandy for me because each
container is its own [supervisord][sup] instance.

So I was interested in some software that would let me manage multiple
[supervisord][sup] instances in a single page.  Turns out that there
are several tools lsted [here][suptools].  Unfortunately none of these
worked for me.

So with the power of open source I rolled my own.  I based mine on [supervisorui][supui].
Unfortunately, [supervisorui][supui] hasn't been updated in 10 years.  What is worse
it depends on a `Silex` library that doesn't seem to exist anymore.

So I ripped out a bunch of complex functionality and recreated it as
[supervisorui-redone][gh].


![screenshot](https://raw.githubusercontent.com/TortugaLabs/supervisorui-redone/main/img/screenshot.png)

It is indeed a quick and dirty implementation, unlike the original
[supervisorui][supui] that has heavier JavaScript dependencies.
[supervisorui][supui] is mostly a JavaScript applications and simply
uses `php` for backend access to the [supervisord][sup].  I assume
that it would make it more interactive.

My re-worked version is basically a PHP application.

As such, I removed the dependancies on

  * [Silex](http://silex.sensiolabs.org/)
  * [Twitter Bootstrap](http://twitter.github.com/bootstrap/) javascript, only
    CSS is in use.
  * [jQuery](http://jquery.com/)
  * [Backbone.js](http://documentcloud.github.com/backbone/)

Also fixed [Incutio XML-RPC Library](http://scripts.incutio.com/xmlrpc/)
so that it works with PHP8.


  [sup]: http://supervisord.org/index.html
  [suptools]: http://supervisord.org/plugins.html#dashboards-and-tools-for-multiple-supervisor-instances
  [supui]: https://github.com/Tabcorp/supervisorui/
  [gh]: https://github.com/TortugaLabs/supervisorui-redone



