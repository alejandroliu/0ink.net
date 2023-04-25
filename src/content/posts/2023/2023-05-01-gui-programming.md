---
title: Personal thoughts on GUI programming
tags: desktop, idea, library, linux, scripts
---
I have been programming for about 40 years.  Going through a lot of different languages
and programming paradims.

Lately most of my programming is done in:

- [bash/shell][bash] script
- [Python][python]
- [PHP][php], with some bits in [JavaScript][javascript]

So lately, after hitting some bugs in a recent update of the [MATE][mate] desktop environment
I decided to re-do my desktop set-up switching to a new desktop environment.  After testing
several desktop environments I decided for [LxQt][lxqt] because of its minimalistic feel.
While doing this, I figured, I needed some GUI scripts to spice things up.

In the past, most of these simple GUI scripts, I have done them in [TCL/TK][tcl]. So I am very
familiar writting GUI applications using [TCL][tcl].

Since, [TCL] is not a popular language (in a [survey at the beginning of 2023][survey] it
wasn't even mentioned.  On the other hand, [python][python] seemed quite popular.

I decided, that it probably would be a good idea to write these GUI scripts in [python][python].
Since, in [python][python] you can also get a [tkinter][tkinter] module that seems to be
quite ubiquitous.  i.e. _"batteries included"_ distributions have it, and most Linux distributions
package it.  Also, since is supposed to be a straight-port from [TCL/TK][tcl] I though that
the learning curve would be pretty smooth.

So, I tried it using for a couple of scripts, a [volume control][patoggle] and a [macro recording][xm]
utilities.

I would have to admit that I find writting [python3 tkinter][tkinter] GUIs very awkward.  Because
it is a direct translation of [TCL/TK][tcl] I keep thinking in [TCL][tcl] terms, but things do
not work the same in [python][python].

Because, it was easier for me, the other GUI utilities, [local-startup][local-startup] and
[hk_helper][hk_helper] were written in [TCL][tcl]

So, my conclusion is that while I can write GUI scripts in [python][python], the learning
curve is still steep, and I need to get a lot more experience before I can consider myself
familiar with it.

Also, the decision to switch to [tcl][tcl] for the scripts that were eventually written
in [tcl][tcl], was driven not just for the familiarity, but because the use case required
spawning new processes, which in [tcl][tcl] is far easier than in [python][python].

Sometimes I think using a more _pythonic_ GUI library instead of [tkinter][tkinter] would
be better.  But, like I mentioned earlier, [tkinter][tkinter] gets the job done, and can
be found with [python][python] very often.

  [php]: https://www.php.net/manual/en/intro-whatis.php
  [javascript]: https://en.wikipedia.org/wiki/JavaScript
  [python]: https://www.python.org/
  [bash]: https://www.gnu.org/software/bash/
  [mate]: https://mate-desktop.org/
  [lxqt]: https://lxqt-project.org/about/
  [tcl]: https://www.tcl.tk/
  [survey]: https://distantjob.com/blog/programming-languages-rank/
  [tkinter]: https://en.wikipedia.org/wiki/Tkinter
  [patoggle]: https://github.com/alejandroliu/0ink.net/tree/master/snippets/pa-hints
  [xm]: https://github.com/alejandroliu/0ink.net/tree/master/snippets/xmpy
  [local-startup]: https://github.com/alejandroliu/0ink.net/tree/master/snippets/local-startup
  [hk_helper]: https://github.com/alejandroliu/0ink.net/tree/master/snippets/global-hotkeys
  
  
