---
title: Python GUI
date: "2023-08-27"
author: alex
tags: python, windows
---
![pygui]({static}/images/2024/pygui.jpg)


After looking a multiple options of GUI programming under [python][python] I
eventually settled for [tkinter][tkinter].  The main reason was that
[tkinter][tkinter] is very ubiquitous and initially though the learning
curve wuld have shorter as I was very used to GUI programming using
[TCL/TK][tcl].  Turned out that what I known [TCL/TK][tcl] did not translate
very well to [tkinter][tkinter] in [python][python].

Also I found out some **BASIC** features that I was used to in [TCL/TK][tcl] were
not available in [python][python].  For example:

- Implementing optional scrollbars
- Scrollable frames

At some time I considered using [kivy][kivy] but at the end, I did not.  Since the
main advantage for it is that you can create mobile apps.  But since my primary
phone is an iPhone, I don't think I would be able to create iPhone apps
due to Apple's walled garden restrictions.

So try things out, I wrote a couiple of scripts:

- [patoggle][patoggle] \
  This one is not that interesting as it only shows things on the screen but does not
  have any inputs.  But I though was a good starting project.
- [xprtmgr][xprtmgr] \
  This is a more complete application.  It was a good learning experience.

I assume that as I get more experience, things should be easier.

  [python]: https://www.python.org/
  [tkinter]: https://en.wikipedia.org/wiki/Tkinter
  [tcl]: https://www.tcl.tk/
  [kivy]: https://kivy.org/
  [patoggle]: https://github.com/alejandroliu/0ink.net/tree/main/snippets/2020/pa-hints
  [xprtmgr]: https://github.com/alejandroliu/0ink.net/tree/main/snippets/2023/xprtmgr


