import os
import select
import shlex
import signal
import socket
import sys

import hkcfg


class GHKApplet:
  applet = None
  driver = None

  def dispatch(self, ev: list):
    raise NotImplemented("GHKApplet.dispatch: not implemented")
  def sock_read():
    data = ''
    while len(data) == 0 or data[-1] != '\n':
      rd = GHKApplet.driver.recv(4096)
      if len(rd) == 0:
        sys.exit(1)
        return
      data += rd.decode()

    if GHKApplet.applet is None: return

    data = data.split('\n')
    for ln in data:
      ev = shlex.split(ln)
      if len(ev) == 0: continue
      GHKApplet.applet.dispatch(ev)

class Macros(GHKApplet):
  def __init__(self):
    self.caller = None
    self.keys = []

  def record(self):
    self.caller = GHKApplet.applet
    self.keys = []
    GHKApplet.applet = self

  def play(self):
    print('Playing')
    GHKApplet.driver.send(f'uisyn\n'.encode())
    for kc in self.keys:
      print('send',kc)
      GHKApplet.driver.send(f'uikey {kc[0]} {kc[1]}\n'.encode())
    GHKApplet.driver.send(f'uisyn\n'.encode())

  def dispatch(self, ev: list):
    if ev[0] != 'keyevent': return
    if ev[4] == 'up' and len(self.keys) == 0: return

    if ev[3] == 'KEY_PLAYPAUSE' and ev[4] == 'down':
      # Finished recording
      GHKApplet.applet = self.caller
      print('Finished recording',len(self.keys))
      print(self.keys)
      return

    print('recording',ev)
    self.keys.append([ev[3],ev[4]])


class HotKeys(GHKApplet):
  def __init__(self, cfg: str):
    self.hotkeys, self.actions = hkcfg.read_hk_cfg(cfg)
    self.macros = Macros()

  def dispatch(self, ev: list):
    if ev[0] != 'keyevent' or ev[4] != 'down': return
    while len(ev) < 6: ev.append('')
    # ~ print(ev)
    if not ev[3] in self.hotkeys: return
    if not ev[5] in self.hotkeys[ev[3]]: return

    action = self.hotkeys[ev[3]][ev[5]]
    print('action',action,self.actions[action])
    cmd = self.actions[action]
    match cmd[0]:
      case 'record_macro'|'record':
        self.macros.record()
      case 'play_macro'|'play':
        self.macros.play()
      case 'exec':
        try:
          pid = os.fork()
        except OSError as e:
          print(f'Error spawning process {e}')
          return
        if pid == 0:
          os.execvp(cmd[1],cmd[1:])
          print(f'Error {cmd}')
          sys.exit(1)
        return
      case _:
        print(f'Unknown command: {cmd[0]}')

if __name__ == '__main__':
  GHKApplet.driver = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
  GHKApplet.driver.connect('socket')
  hotkeys = HotKeys('config.txt')
  GHKApplet.applet = hotkeys
  signal.signal(signal.SIGCHLD, signal.SIG_IGN)

  while True:
    rds = [ GHKApplet.driver.fileno() ]
    r,_,_ = select.select(rds, [], [])
    if GHKApplet.driver.fileno() in r:
      GHKApplet.sock_read()



