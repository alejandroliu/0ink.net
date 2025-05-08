---
title: More Python GUI programming
date: "2025-05-05"
author: alex
tags: python, javascript
---
just talk about using after and also tkinter.createfilehandler -- UNIX specific.

[[../2024/2024-03-01-python-gui.md|Python GUI]]

Using select: still need to do after to poll file descriptors.

Using asyncio, requires integrating with the Tcl/Tk main loop via after.

after + queue.Queue

Another:

https://pypi.org/project/async-tkinter-loop/

https://basillica.medium.com/working-with-queues-in-python-a-complete-guide-aa112d310542


  [filehandler]: https://docs.python.org/3/library/tkinter.html#file-handlers
  [tcl]: https://www.tcl.tk/
  [tkinter]: https://en.wikipedia.org/wiki/Tkinter
  [python]: https://www.python.org/
  [kivy]: https://kivy.org/

