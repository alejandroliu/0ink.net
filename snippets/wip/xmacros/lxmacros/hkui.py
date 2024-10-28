#!python3
import queue as Q
import sys
import threading as tt
import time
import tkinter as Tk

class Notice(Tk.Toplevel):
  def __init__(self, text, **kwargs):
    print(kwargs)
    super().__init__(**kwargs)
    self.message = Tk.Message(self, text = text)
    self.message.pack(padx = 10, pady = 10, side = 'top')
    self.wm_overrideredirect(True)
    self.wm_resizable(False,False)
    self.geometry('-48+48')

  def run(msg, delay = None):
    if delay is None: delay = Notice.DELAY

    notice = Notice(str(data))
    notice.after(delay, notice.destroy)

class TkUI:
  IPC_EVENT = '<<ipcevent1>>'

  queue = None
  root = None
  thread = None
  def recv(evt):
    print('Received IPC in thread:',tt.get_ident())
    print(evt)
    data = TkUI.queue.get()
    print(data)
    Notice.run(str(data))

  def send(msg):
    print('Send IPC in thread:',tt.get_ident())
    TkUI.queue.put(msg)
    TkUI.root.event_generate(TkUI.IPC_EVENT, when='tail',state=int(time.time()))
  def init():
    if TkUI.queue is None:
      TkUI.queue = Q.Queue()
    if TkUI.root is None:
      TkUI.root = Tk.Tk()
      TkUI.root.option_add('*Font', 'Helvetica 14 bold')
      TkUI.root.wm_overrideredirect(True)
      TkUI.root.wm_resizable(False,False)
      TkUI.root.bind(TkUI.IPC_EVENT,TkUI.recv)
    # ~ self.root.wm_withdraw()
  def mainloop():
    print('Main GUI thread:',tt.get_ident())
    TkUI.init()
    TkUI.root.mainloop()
  def start_ui():
    if TkUI.thread is None:
      TkUI.thread = tt.Thread(target = TkUI.mainloop)
      TkUI.thread.start()

if __name__ == '__main__':
  import shlex
  print('Main worker thread:',tt.get_ident())
  TkUI.start_ui()

  while True:
    sys.stderr.write('Reading stdin: ')
    sys.stderr.flush()
    data = sys.stdin.readline()
    if len(data) == 0: sys.exit(0)
    data = shlex.split(data)
    if len(data) == 0: continue
    TkUI.send(data)

