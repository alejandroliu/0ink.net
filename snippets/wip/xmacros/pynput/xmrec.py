
import tkinter as tk
from tkinter import ttk

from pynput import mouse, keyboard

import sys
import os

DELAY = 5000
TMPFILE = 'xmacro.tmp'
MACROFILE = 'xmacro.py'

class Notice(tk.Frame):
  def __init__(self, master,text):
    super().__init__(master)

    self.pack(padx = 10, pady = 10)
    self.message = tk.Message(self, text = text)
    self.message.pack(padx = 10, pady = 10, side = 'top')

  def run(msg, delay = DELAY):
    root = tk.Tk()
    root.option_add('*Font', 'Helvetica 14 bold')
    root.wm_overrideredirect(True)
    root.wm_resizable(False,False)
    root.geometry('-48+48')

    notice = Notice(root,msg)
    notice.after(DELAY, lambda notice: notice.quit(), notice)
    notice.mainloop()
    root.wm_withdraw()

class AskMode(tk.Frame):
  def set_mode(self, label, kbd, mouse):
    print(label)
    self.vmode.set(label)
    self.do_mouse = mouse
    self.do_keyboard = kbd

  def set_kbd(self):
    self.set_mode('keyboard', True, False)
  def set_mouse(self):
    self.set_mode('mouse', False, True)
  def set_all(self):
    self.set_mode('keyboard & mouse', True, True)

  def ok(self):
    self.done = True
    self.quit()

  def __init__(self, master):
    super().__init__(master)
    self.pack(padx = 10, pady = 10)

    b = tk.Label(self,text = 'Record: ')
    b.grid(row = 0, column = 0)

    self.vmode = tk.StringVar()
    self.vmode.set('keyboard')

    self.do_mouse = False
    self.do_keyboard = True

    self.mbtn = tk.Menubutton(self, textvariable = self.vmode, relief = tk.RAISED, takefocus = 1)
    self.mbtn.grid(row = 0, column = 1)
    self.mbtn.focus()

    self.menu = tk.Menu(self.mbtn, tearoff = False)
    self.menu.add_command(label='keyboard', command = self.set_kbd)
    self.menu.add_command(label='mouse', command = self.set_mouse)
    self.menu.add_command(label="mouse & keyboard", command = self.set_all)

    self.mbtn['menu'] = self.menu

    self.done = False
    self.okbtn = tk.Button(self,text = ' Ok ', command = self.ok);
    self.okbtn.grid(row = 1, column = 0, columnspan = 2, padx = 10, pady = 10)

    master.bind('<Key-Return>', self.b_enter )
    master.bind('<Key-Escape>', self.b_escape )

  def run():
    root = tk.Tk()
    root.option_add('*Font', 'Helvetica 12')
    root.option_add('*Button.font', 'Helvetica 12 bold')
    root.eval('tk::PlaceWindow . center')

    ask = AskMode(root)
    ask.mainloop()
    root.wm_withdraw()
    return (ask.done, ask.do_keyboard, ask.do_mouse)

  def b_escape(self,event):
    self.quit()
  def b_enter(self,event):
    self.ok()

class MouseRecorder():
  def on_move(x, y):
    ...
    # ~ print('Pointer moved to {0}'.format(
        # ~ (x, y)))

  def on_click(x, y, button, pressed):
    if x != MouseRecorder.x or y != MouseRecorder.y:
      print('  mctl.position = ({x}, {y})'.format(x = x, y = y))
      MouseRecorder.x = x
      MouseRecorder.y = y
    if pressed:
      print('  mctl.press({b})'.format(b = button))
    else:
      print('  mctl.release({b})'.format(b = button))

  def on_scroll(x, y, dx, dy):
    if x != MouseRecorder.x or y != MouseRecorder.y:
      print('  mctl.position = ({x}, {y})'.format(x = x, y = y))
      MouseRecorder.x = x
      MouseRecorder.y = y
    print('  mctl.scroll({dx},{dy}'.format(dx=dx, dy=dy));

  def __init__(self):
    MouseRecorder.x = -1
    MouseRecorder.y = -1

    self.listener = mouse.Listener(
        on_move = MouseRecorder.on_move,
        on_click = MouseRecorder.on_click,
        on_scroll = MouseRecorder.on_scroll)
    self.listener.start()
    print('from pynput import mouse')
    print('from pynput.mouse import Button')
    print('mctl = mouse.Controller()')

class KeyboardRecorder:
  debounce_map = set()

  def keycmd(mode,key):
    print('  kbd.{mode}({key})'.format(
              mode = mode,
              key = key))

  def on_press(key):
    if not str(key) in KeyboardRecorder.debounce_map:
      KeyboardRecorder.debounce_map ^= { str(key) }

    sys.stderr.write(' key={key} type={tt}\n'.format(key = key, tt = type(key)))
    if key == keyboard.Key.f12 or key == keyboard.Key.media_play_pause:
        # Stop listener
        return False
    KeyboardRecorder.keycmd('press',key)
    # ~ try:
      # ~ print('alphanumeric key {0} pressed'.format(
            # ~ key.char))
    # ~
      # ~ print('special key {0} pressed'.format(
          # ~ key))

  def on_release(key):
    if not str(key) in KeyboardRecorder.debounce_map:
      sys.stderr.write('Debouncing {key}\n'.format(key=key))
      return
    if key == keyboard.Key.f12 or key == keyboard.Key.media_play_pause:
        # Stop listener
        return False
    KeyboardRecorder.keycmd('release',key)

  def __init__(self):
    sys.stderr.write('MOD: {mods}\n'.format(mods=keyboard.Controller.modifiers))
    if keyboard.Controller.ctrl_pressed:
      sys.stderr.write('CTRL is down\n')
    self.listener = keyboard.Listener(
        on_press=KeyboardRecorder.on_press,
        on_release=KeyboardRecorder.on_release)
    self.listener.start()
    print('from pynput import keyboard')
    print('from pynput.keyboard import Key')
    print('kbd = keyboard.Controller()')

def record(do_mouse = True, do_keyboard = True):
  thread = None
  if do_mouse: thread = MouseRecorder()
  if do_keyboard: thread = KeyboardRecorder()

  if thread is None:
    Notice.run('Not capturing any events')
    sys.exit(1)

  print('import xmplay')
  print('def run():');
  print('  pass');

  Notice.run('''
Recording macro...

Press <media-play-pause> to stop recording.
''')
  thread.listener.join()
  print('xmplay.args(run)')

if __name__ == '__main__':
  if len(sys.argv) != 2 and len(sys.argv) != 3:
    print('Usage: {0} k|q')
    sys.exit(1)

  workdir = os.getenv('XDG_RUNTIME_DIR','/tmp')
  if workdir[-1:] != '/': workdir += '/'

  if sys.argv[1] == 'k':
    okcancel = True
    do_mouse = False
    do_kbd = True
  elif sys.argv[1] == 'q':
    okcancel, do_kbd, do_mouse = AskMode.run()
  else:
    okcancel = False

  if not okcancel: sys.exit(1)

  sys.stdout = open(workdir + TMPFILE,'w')
  record(do_mouse, do_kbd)
  if os.path.isfile(workdir + MACROFILE):
    os.unlink(workdir + MACROFILE)
  os.rename(workdir + TMPFILE, workdir + MACROFILE)

  if len(sys.argv) == 3:
    Notice.run(sys.argv[2])

  sys.exit(0)

