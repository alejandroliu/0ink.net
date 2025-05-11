---
title: More Python GUI programming
date: "2025-05-05"
author: alex
tags: python, javascript, application, network, setup, feature, management, windows,
  linux
---
[toc]
***

In a previous article, I wrote about [[../2024/2024-03-01-python-gui.md|Python GUI]] programming.

I used to write simple User Interfaces with [Tcl/Tk][tcl].  Nowadays
I find writing [Python][python] more often, so obviously I would
start writing user interfaces in [Python][python] with [tkinter][tkinter],
because of my [Tcl/Tk][tcl] background.

While [Tcl/Tk][tcl] has a complete event driven architecture, suitable for scripting,
[Python][python] has a richer set of programming paradims to choose from.

One common pattern is GUI programming is to use threading to split the UI and
the computations into separate threads.  This has the advantage of making
the computation thread only about doing calculations, while keeping the
UI very responsive.

In [Tcl/Tk][tcl] because it did not support threading natively, you would
either have to split the computation tasks into small units or 
use multiple processes.

Both approaches came with different set of disadvantages.

Splitting computation tasks into small units meant that you in essence
had to program in a cooperative multitasking environment, and split
a large task into smaller tasks so that the UI wouldn't block for
long periods of time making it unresponsive.  Most of the programming
effort would be then spent creating the smaller units, and making
sure that the application wouldn't block.

Alternatively, you could split your program into multiple processes using
network sockets and fileevent handlers to keep the UI responsive.  In here
a lot of programming effort is spent coordinating and sharing the data between
processes.

# Using threads with Python and Tkinter

With [python][python], the UI thread and separate computation thread
would have been easy to implement becase [python][python] supports
threads natively.  Unfortunatley, because [tkinter][tkinter]
is based on [Tcl/Tk][tcl], it does not really support multiple threads
and has potential concurrency issues.

## Impelementation using queue.Queue

There is essentially one main approach to implement this in a 
thread safe way.  To use a [python][python] synchronization
primitive such as [queue.Queue][q], and poll it from an `after`
function on a regular basis.

This is an exampe using [queue.Queue]:

```python
import tkinter as tk
import threading
import time
import queue

class App:
    def __init__(self, root):
        self.root = root
        self.root.title("Counting UI")

        # Create UI elements
        self.listbox = tk.Listbox(root, width=40, height=20)
        self.listbox.pack()

        self.close_button = tk.Button(root, text="Close", command=self.close)
        self.close_button.pack()

        # Create a thread-safe queue
        self.queue = queue.Queue()

        # Start the counting thread
        self.running = True
        self.thread = threading.Thread(target=self.counter_thread, daemon=True)
        self.thread.start()

        # Start polling the queue using after()
        self.poll_queue()

    def counter_thread(self):
        """Thread that counts from 1 to 60, adding values to the queue each second."""
        for i in range(1, 61):
            if not self.running:
                break
            self.queue.put(str(i))
            time.sleep(1)

        # Signal completion
        self.queue.put("DONE")

    def poll_queue(self):
        """Polls the queue every 100ms and updates the listbox."""
        while not self.queue.empty():
            item = self.queue.get()
            if item == "DONE":
                self.close()
                return
            self.listbox.insert(tk.END, item)

        if self.running:
            self.root.after(100, self.poll_queue)  # Schedule next poll

    def close(self):
        """Closes the application."""
        self.running = False
        self.root.quit()

# Run the application
if __name__ == "__main__":
    root = tk.Tk()
    app = App(root)
    root.mainloop()

```

This Python script creates a simple GUI application using Tkinter and manages
background processing using a thread and a queue. Here's what it does:

- It opens a Tkinter window with a listbox and a "Close" button.
- A separate thread runs in the background, counting from 1 to 60, adding each number to
  a queue once per second.
- The main thread (UI thread) polls the queue every 100ms, retrieving numbers and displaying
  them in the listbox.
- When counting reaches 60, the script signals completion with `"DONE"`, triggering the
  application to close.

## Key Components

1. **Tkinter UI Setup:** 
   - A listbox is used to display the counting numbers.
   - A "Close" button is provided to manually stop execution.
2. **Threading (`counter_thread` function):**
   - Runs independently from the UI thread to avoid freezing the interface.
   - Adds numbers 1 to 60 into the queue every second.
   - Uses `"DONE"` as a termination signal.
3. **Queue for Communication (`queue.Queue()`):**
   - Ensures thread-safe interaction between the worker thread and the main UI thread.
   - Acts as a buffer for numbers produced by the worker thread.
4. **Polling Mechanism (`poll_queue` function):**
   - Checks the queue every 100ms.
   - Retrieves numbers and updates the listbox.
   - Recognizes `"DONE"` as the termination condition and shuts down the UI.
5. **Application Lifecycle (`close` function):**
   - Stops the counting thread gracefully.
   - Closes the application window.

## **Why Use Threads and Queues?**

- **Threading prevents UI freezing** since time delays (`time.sleep`) inside Tkinter's main
  loop would block interactions.
- **Queues ensure thread safety**, avoiding direct UI modifications from background threads.
- **Polling allows non-blocking event handling**, letting Tkinter remain responsive.


# Alternative implementation using Pipe's

For comparison, we can achieve a similar result using select and UNIX Pipes.  This in principle
is very similar to what you would do using [Tcl/Tk][tcl]:

```python

import tkinter as tk
import threading
import time
import os
import select

class App:
    def __init__(self, root):
        self.root = root
        self.root.title("Counting UI")

        # Create UI elements
        self.listbox = tk.Listbox(root, width=40, height=20)
        self.listbox.pack()

        self.close_button = tk.Button(root, text="Close", command=self.close)
        self.close_button.pack()

        # Create a pipe
        self.pipe_r, self.pipe_w = os.pipe()

        # Start the thread
        self.running = True
        self.thread = threading.Thread(target=self.counter_thread)
        self.thread.start()

        # Start polling the pipe using after()
        self.poll_pipe()

    def counter_thread(self):
        """Thread that counts from 1 to 60, writing to the pipe each second."""
        for i in range(1, 61):
            if not self.running:
                break
            os.write(self.pipe_w, f"{i}\n".encode())
            time.sleep(1)

        # Signal completion by writing "DONE" to the pipe
        os.write(self.pipe_w, "DONE\n".encode())

    def poll_pipe(self):
        """Polls the pipe every 100ms using select() and updates the listbox."""
        readable, _, _ = select.select([self.pipe_r], [], [], 0)
        if readable:
            try:
                data = os.read(self.pipe_r, 1024).decode()
                for line in data.splitlines():
                    if line == "DONE":
                        self.close()  # Call close method in UI thread
                        return
                    self.listbox.insert(tk.END, line)
            except OSError:
                pass  # Pipe closed

        if self.running:
            self.root.after(100, self.poll_pipe)  # Schedule next poll

    def close(self):
        """Closes the application."""
        self.running = False
        os.close(self.pipe_r)
        os.close(self.pipe_w)
        self.root.quit()

# Run the application
if __name__ == "__main__":
    root = tk.Tk()
    app = App(root)
    root.mainloop()
```

Both implementations serve the same purpose—communicating between a background
thread and the Tkinter UI thread—but they differ in efficiency, complexity, and reliability.
Here's a comparison:

## Comparison of Queue vs. Pipe + Select

| Feature                | Queue (`queue.Queue`)  | Pipe + Select (`os.pipe() + select.select()`) |
|------------------------|-----------------------|-----------------------------------|
| **Ease of Use**        | Simple API (`put/get`) | Requires handling raw byte streams |
| **Polling Mechanism**  | Uses `queue.get()` (blocking or timeout-based) | Requires `select.select()` polling |
| **Code Readability**   | Cleaner and more structured | More low-level, harder to maintain |
| **Data Format**        | Stores Python objects (strings, numbers) | Requires encoding/decoding byte streams |

## **Which One is Better?**

**Using `queue.Queue` is generally better** in the context of Python multithreading and GUI applications:

- **More Pythonic and intuitive:** Python's queue mechanisms integrate naturally with threading.
- **Automatic thread safety:** No need for manual locking or polling overhead.
- **Better resource management:** No need to manually open and close OS-level pipes.
- **Cross-platform reliability:** Works consistently across Windows, macOS, and Linux.

However, **Pipe + Select is useful in certain cases**:

- When dealing with **multi-processing (instead of multi-threading)**, since `queue.Queue` is thread-safe but **not process-safe** (for processes, `multiprocessing.Queue` is preferred).
- If interacting with **external system processes**, where pipes and low-level I/O are necessary.

For a Tkinter-based GUI with multi-threading, **`queue.Queue` is the better choice** -
it's safer, simpler, and requires less manual handling compared to pipe-based synchronization.

# Using File handlers

The alternative implementation using UNIX pipe's is interesting because it can be
modified to use [filehandlers][fe].  This is closer to a [Tcl/Tk][tcl] implementation
which would probably use [fileevent][fe].

```python

import tkinter as tk
import threading
import time
import os

class App:
    def __init__(self, root):
        self.root = root
        self.root.title("Counting UI")

        # Create UI elements
        self.listbox = tk.Listbox(root, width=40, height=20)
        self.listbox.pack()

        self.close_button = tk.Button(root, text="Close", command=self.close)
        self.close_button.pack()

        # Create a pipe
        self.pipe_r, self.pipe_w = os.pipe()

        # Start the thread
        self.running = True
        self.thread = threading.Thread(target=self.counter_thread)
        self.thread.start()

        # Register the pipe with Tkinter's event loop
        self.root.createfilehandler(self.pipe_r, tk.READABLE, self.read_pipe)

    def counter_thread(self):
        """Thread that counts from 1 to 60, writing to the pipe each second."""
        for i in range(1, 61):
            if not self.running:
                break
            os.write(self.pipe_w, f"{i}\n".encode())
            time.sleep(1)

        # Signal completion by writing "DONE" to the pipe
        os.write(self.pipe_w, "DONE\n".encode())

    def read_pipe(self, file_descriptor, event_mask):
        """Reads from the pipe and updates the listbox."""
        try:
            data = os.read(file_descriptor, 1024).decode()
            for line in data.splitlines():
                if line == "DONE":
                    self.close()  # Call close method in UI thread
                    return
                self.listbox.insert(tk.END, line)
        except OSError:
            pass  # Pipe closed

    def close(self):
        """Closes the application."""
        self.running = False
        os.close(self.pipe_r)
        os.close(self.pipe_w)
        self.root.quit()

# Run the application
if __name__ == "__main__":
    root = tk.Tk()
    app = App(root)
    root.mainloop()

```

Both approaches use **pipes (`os.pipe()`)** for communication between a background thread
and the Tkinter UI thread. However, they differ in how they integrate with Tkinter's event
loop. Here’s a breakdown:

##  Event Polling Mechanism

| Feature | Pipe + Select (`select.select()`) | Pipe + `createfilehandler()` |
|---------|---------------------------------|-------------------------------|
| **Event Handling** | Polls the pipe every 100ms using `select.select()` | Directly registers a pipe handler with Tkinter |
| **Polling Overhead** | Requires frequent polling even when there’s no data | More efficient—Tkinter triggers event on readable data |
| **Performance** | Slightly wasteful due to constant polling | More optimal as event processing is handled natively by Tkinter |
| **Responsiveness** | UI remains responsive but polling introduces some delay | Immediate handling of incoming data with better responsiveness |

## Code Complexity & Maintainability

| Feature | Pipe + Select | Pipe + `createfilehandler()` |
|---------|--------------|------------------------------|
| **Complexity** | Requires manual polling with `select.select()` | Simpler, as Tkinter automatically processes pipe events |
| **Readability** | More boilerplate code for polling | More concise and integrates cleanly with Tkinter |
| **Ease of Debugging** | Requires handling timeout and manual checks | Easier to debug since Tkinter invokes handler only when needed |

## Which One is Better?

Both approaches are Linux/UNIX dependant, so they wouldn't work on MS Windows.  If that is
not a requirement, is obvious that using File Handlers is the better approach as avoids polling
overhead, giving better performance.

# Alternative approaches

I found [Asynchronous Tkinter Mainloop][atm] which is an asynchronous implementation
of the mainloop for tkinter. This allows using async handler functions. It is intended to be
as simple to use as possible. No fancy unusual syntax or constructions - just use an
alternative function instead of root.mainloop() and wrap asynchronous handlers into a
helper function.

This is interesting if you are used to using [Python][python]'s [asyncio][aio].  However
keep in mind that this is very similar to using "after+poll" approach mentioned earlier.


# Conclusion

In conclusion, while [Tkinter's][tkinter] threading limitations stem from its [Tcl/Tk][tcl]
foundation, various strategies exist to maintain a responsive UI alongside background
computations.
Using [queue.Queue][q] provides the most Pythonic and thread-safe approach,
ensuring clear communication between worker threads and the UI.
Pipes and file handlers, while viable, introduce added complexity and platform dependencies.
Meanwhile, asynchronous frameworks like [asyncio][aio] and event-driven alternatives further
expand possibilities these suffer with the same polling overhead as other solutions.

Ultimately, the choice depends on your application's needs—whether you prioritize simplicity,
efficiency, or compatibility. If responsiveness and ease of implementation are your goals,
[queue.Queue][q] stands as the most robust option.
However, developers familiar with lower-level event-driven architectures may find pipes
and file handlers more suitable.
Exploring these approaches helps refine a developer’s understanding of concurrency in GUI
applications while balancing usability, performance, and maintainability.




  [fh]: https://docs.python.org/3/library/tkinter.html#file-handlers
  [tcl]: https://www.tcl.tk/
  [fe]: https://www.tcl-lang.org/man/tcl8.6/TclCmd/fileevent.htm
  [tkinter]: https://en.wikipedia.org/wiki/Tkinter
  [python]: https://www.python.org/
  [se]: https://docs.python.org/3/library/select.html
  [q]: https://docs.python.org/3/library/queue.html
  [atm]: https://github.com/insolor/async-tkinter-loop
  [aio]: https://docs.python.org/3/library/asyncio.html

