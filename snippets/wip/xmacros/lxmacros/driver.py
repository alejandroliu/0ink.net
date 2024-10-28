#!python3
import evdev
import os
import select
import shlex
import socket
import subprocess
import sys
from argparse import ArgumentParser

'''
Main lxmacros implementation
'''

class Channel:
  '''Base channel'''

  ios = dict()
  '''Table containing Input devices and Socket clients'''
  def __init__(self, fd : int):
    '''Channel constructor

    :param int fd: file descriptor used in select
    '''
    self.fd = fd
    Channel.ios[fd] = self
  def fileno() -> int:
    '''Returns file descriptor for select calls

    :returns int: file descriptor for this channel
    '''
    return self.fd
  def read(self):
    '''Implement read operations.

    *Not implemented in the abstract Channel class*
    '''
    raise NotImplemented("Channel.read: not implemented")
  def send(self,msg: str):
    '''Implement write operations.

    :param str msg: Message to send

    *It is an NoOp in the abstract Channel class*
    '''
    pass
  def broadcast(msg: str):
    '''Send message to all channels

    :param str msg: message to broadcast
    '''
    q = list(Channel.ios.keys())
    for client in q:
      Channel.ios[client].send(msg)

  def main_loop():
    '''Main loop'''
    while True:
      r,_,_ = select.select(Channel.ios, [], [])
      for fd in r:
        if fd in Channel.ios: Channel.ios[fd].read()


class Socket(Channel):
  '''Base socket channel'''
  def __init__(self, sock : socket.socket):
    '''Base socket constructor

    :param socket.socket sock: Socket to use
    '''
    self.socket = sock
    super().__init__(sock.fileno())

class Server(Socket):
  '''Server socket class

  This socket accepts incoming client connections
  '''
  def check_server(path: str) -> bool:
    '''Static function: Check if the server is already running

    :param str path: path to UNIX socket
    :returns bool: True if not running, False, if running
    '''
    # Try to connect to it
    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
      client.connect(path)
    except FileNotFoundError:
      return True
    except ConnectionRefusedError:
      os.unlink(path)
      return True
    # Succesful connection!
    return False

  def __init__(self, path: str):
    '''Server constructor

    :param str path: path for UNIX socket
    '''
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(path)
    server.listen(1)
    super().__init__(server)
    self.path = path
  def read(self):
    '''Read implementation, accepts new client connections and adds
    them to the channels table
    '''
    newsock,_ = self.socket.accept()
    Client(newsock)
    newsock.setblocking(False)

class Client(Socket):
  '''Client connections'''
  ui = None
  '''UInput handler'''
  def __init__(self, sock: socket.socket):
    '''Client constructor

    :param socket.socket sock: new client socket
    '''
    super().__init__(sock)
    if Client.ui is None:
      Client.ui = evdev.UInput()
  def close_sock(self):
    '''Close active connection'''
    del Channel.ios[self.fd]
    self.socket.close()

  def run_command(self, command: str):
    '''Execute incoming commands

    :param str command: command to execute
    '''
    print(command)
    command = shlex.split(command)
    if len(command) == 0: return

    if command[0] == 'quit':
      sys.exit(0)
    elif command[0] == 'rescan':
      InpDevice.scan_evdevs()
      self.send("OK\n")
    elif command[0] == 'uisyn':
      Client.ui.syn()
      self.send("OK\n")
    elif command[0] == 'uikey' and len(command) >= 3:
        print(command)
        try:
          keycode = int(command[1]) if command[1].isdigit() else evdev.ecodes.ecodes[command[1]]
        except KeyError:
          self.send(f'Error Keycode: {command[1]}\n')
          return
        if command[2] == 'up':
          keyval = 0
        elif command[2] == 'down':
          keyval = 1
        elif command[2].isdigit():
          keyval = int(command[2])
        else:
          self.send(f'Error keyval {command[2]}\n')
          return
        print(f'Sending {keycode} {keyval}')
        Client.ui.write(evdev.ecodes.EV_KEY, keycode , keyval)
        self.send("OK\n")
    else:
      self.send(f"Unknown command {command[0]}\n")

  def read(self):
    '''Accepts commands from the client'''
    data = ''
    while len(data) == 0 or data[-1] != '\n':
      try:
        rd = self.socket.recv(4096)
      except (BlockingIOError,ConnectionResetError):
        rd = ''
      if len(rd) == 0:
        self.close_sock()
        return
      data += rd.decode()

    data = data.split('\n')
    for ln in data: self.run_command(ln)

  def send(self,msg: str):
    '''Sends messages to client

    :param str msg: Message to send
    '''
    if not self.socket.fileno() in Channel.ios: return
    try:
      self.socket.sendall(msg.encode())
    except BrokenPipeError:
      # Client went away...
      self.close_sock()

    # ~ self.socket.send(msg.encode())

class InpDevice(Channel):
  '''Input device class'''
  MODS = (
    'KEY_LEFTCTRL',
    'KEY_LEFTSHIFT',
    'KEY_LEFTALT',
    'KEY_RIGHTCTRL',
    'KEY_RIGHTSHIFT',
    'KEY_RIGHTALT',
    'KEY_LEFTMETA',
    'KEY_RIGHTMETA'
  )
  '''Modifiers key names'''
  LEDS = ('LED_NUML', 'LED_CAPSL')
  '''LED light names'''

  def check_devpath(path: str) -> bool:
    '''Static function: check if a device is already opened
    :param str path: Input device path
    '''
    for d in Channel.ios.values():
      if not isinstance(d, InpDevice): continue
      if d.path == path: return True
    return False
  def scan_evdevs():
    '''Static function: opens input devices and creates its related channels'''
    for path in evdev.list_devices():
      # Make sure it doesn't exists
      if InpDevice.check_devpath(path): continue
      dev = evdev.InputDevice(path)
      caps = dev.capabilities()
      if not evdev.ecodes.EV_KEY in caps: continue
      if len(caps.get(evdev.ecodes.EV_KEY)) < 10: continue
      if evdev.ecodes.BTN_MOUSE in caps.get(evdev.ecodes.EV_KEY): continue

      # ~ print(dev)
      # ~ print(len(caps.get(evdev.ecodes.EV_KEY)))
      # ~ print(dev.capabilities(verbose=True))
      dev = InpDevice(dev)
  def __init__(self, dev: evdev.InputDevice):
    '''InputDevice Channel constructor

    :param evdev.InputDevice dev: device to use
    '''
    self.dev = dev
    super().__init__(dev.fileno())
  def read(self):
    '''Read input device'''
    for event in self.dev.read():
      if event.type != evdev.ecodes.EV_KEY: continue
      if event.value == evdev.events.KeyEvent.key_up:
        evt = 'up'
      elif event.value == evdev.events.KeyEvent.key_down:
        evt = 'down'
      elif event.value == evdev.events.KeyEvent.key_hold: continue
      else: continue

      rleds = self.dev.leds()
      mods = []
      for i in InpDevice.LEDS:
        if evdev.ecodes.ecodes[i] in rleds:
          if i.startswith('LED_'): i = i[4:]
          mods.append(i)
      rkeys = self.dev.active_keys()
      for i in InpDevice.MODS:
        if evdev.ecodes.ecodes[i] in rkeys:
          if i.startswith('KEY_'): i = i[4:]
          mods.append(i)

      msg = f'keyevent {event.code} {event.value} {evdev.ecodes.KEY[event.code]} {evt} {",".join(sorted(mods))}\n'
      Channel.broadcast(msg)

      # ~ print(msg)
      # ~ print(self.dev.active_keys(verbose=True))
      # ~ print(evdev.categorize(event),event)

  def path(self) -> str:
    '''Device path for input device

    :returns str: file path
    '''
    return self.dev.path

def cli_parse():
  '''Parse command line arguments
  :returns ArgumentParser: commnad line parser
  '''
  cli = ArgumentParser(prog='lxmacrosd',
                        description='Linux Keyboard macros driver')
  cli.add_argument('-m','--mode',
                  help = 'File modes for UNIX socket',
                  type=str, default = None)
  cli.add_argument('-g','--group',
                  help = 'File group for UNIX socket',
                  type=str, default = None)
  cli.add_argument('-s','--socket',
                  help = 'Path to UNIX socket',
                  type=str, default = 'socket')
  return cli


if __name__ == '__main__':
  parser = cli_parse()
  args = parser.parse_args()

  if Server.check_server(args.socket):
    Server(args.socket)
    if not args.group is None:
      # Yes, this is lazy coding...
      subprocess.run(['chgrp',args.group,args.socket])
    if not args.mode is None:
      subprocess.run(['chmod',args.mode,args.socket])
  else:
    sys.stderr.write(f'{server_path} already running\n')
    sys.exit(1)

  InpDevice.scan_evdevs()
  Channel.main_loop()

