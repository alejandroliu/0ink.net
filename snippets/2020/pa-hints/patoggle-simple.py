#!/usr/bin/env python3
# xbps-install python3-notify2 python3-pulsectl

import pulsectl
from collections import namedtuple
from argparse import ArgumentParser, Action
import sys
import os
import signal

# ~ import notify2
import tkinter as tk
from tkinter import ttk


COMMAND = 'patoggle2s'
#
# +------+ Output device
# | icon | Volume level/muted
# +------+ Message
#

DELAY = 4 * 1000


PaCard = namedtuple('PaCard','id name')
'''
PulseAudio card definition
'''
PaOutputProfile = namedtuple('PaOutputProfile', 'card name desc')
'''
PulseAudio Output Profile
'''

pulse = pulsectl.Pulse(COMMAND)
'''
pulse audio object instance
'''

def pa_get_outputs():
  '''
  Get PulseAudio output profiles

  List all the output profiles available on all audio cards.

  :returns PaOutputProfile[], int: Returns a list of PaOutputProfile tupples, and index of the current active profile
  '''
  profiles = []
  current = 0

  cards = pulse.card_list()
  for c in cards:
    cdat = PaCard(c.index, c.name)
    pros =c.profile_list
    for p in pros:
      if not p.available: continue
      if p.n_sinks == 0: continue

      pro = PaOutputProfile(cdat, p.name, p.description)
      if p.name == c.profile_active.name:
        current = len(profiles)
        # ~ print('Active: {card},{pro}'.format(card = cdat.name, pro = pro.name))
      profiles.append(pro)

  return profiles, current

def pa_activate_profile(oprofile):
  '''
  Activate the given output profile

  :param PaOutputProfile oprofile: Output profile to activate
  '''
  cards = pulse.card_list()
  for c in cards:
    if c.name == oprofile.card.name:
      pulse.card_profile_set(c, oprofile.name)
    else:
      pulse.card_profile_set(c, 'off')

class App(tk.Frame):
  def __init__(self, master):
      super().__init__(master)

      self.grid()

      self.icon = ttk.Label(self)
      self.icon.grid(column=0,row=0,rowspan=3)
      self.oprofile = ttk.Label(self,
                          name = 'oprofile')
      self.oprofile.grid(column=1,row=0)
      # ~ self.volume = tk.Scale(self,
                          # ~ # from = 0,
                          # ~ to = 100,
                          # ~ label = 'Volume:',
                          # ~ showvalue = True)
      # ~ self.volume.grid(column=1,row=1)

      self.message = ttk.Label(self,
                              font = 'Helvetica 12')
      self.message.grid(column=1,row=2)

      self.muted = tk.Image('photo', data = '''
        iVBORw0KGgoAAAANSUhEUgAAAHAAAABwCAYAAADG4PRLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAC
        3klEQVR4nO3dTYoUQRCG4dx6Er2FfQqXOiBuxX93Viy9gtfyLC7VsRIcGIbp7Kqo+OvkfSCXRgXx
        0cEwTme1BgAAAAAAAAAAAAAAAAAw82Q9P9ZzOzgo6tl6frZxeARY1Mv1/GqXwyPAYrasTAIsauvK
        JMCC9qxMAixEszIJsAjtyiTAAo6sTAJMZLEyCTCJ1cokwASWK5MAA3msTAIM4rUyCTCA58okQEcR
        K5MAnUStTAJ0cNPiVqZHgM+N6njXNJexMq0D/PK/zneDWnfEoaa5rJVpGeDnB7UsBi4ONc1F/pTp
        FeCnM/WODFwcag5lDz8rwI8XamoGLg41L8oefkaAHzbW3TNwcai5SfbwowN8v7P2loGLQ83Nsocf
        GeDT9fxW1JdBTVH2fNrR91D28CMD7F40XYiPfWpE2e+ys+eh7OFHB9i9Ws8fxXPuhyjKXk3Da8om
        qh2N1+v5q3iWNH14oux1KHv4WQF2PUTNJ1FzlgN9DmUPPzPA7k3TfRJLhNecG7+GALu3jr25htcc
        G7+mALt3Dn25h9ccmr7WALutv6EpE14zbHiGALtzv+AuGV4zaLbCsfbtQC+h4bUDjVY61uRAL+H/
        95c9/GoBikE/oSFmD79SgGLYU1iI2cOvEqA49BUSYvbwKwQojr25h5g9/OwAJaA/1xCzh58ZoAT2
        yB81DY6GKJ+1rOer8t/yR01nzl6ifM5yr0aZELOHHx2gKJ+xPFKrRIjZw48M8KSsL4Oaoqx52tH3
        UPbwIwPs9n5qlqSam2UPPzrAbuvA9wzao+Ym2cPPCLC7NHDNoD1qupnhyy3nBn5k0B413czw9bKH
        A7cYtEdNNzN8wfNu4JaD9qjp6qbxFeuImq645GACXDMyCS76mQBXbU2Ay+4mwXWTE+DC1wlw5fIk
        uPR8Arx2YAK8+GMSvHpnArz8agK8fm4SvAByAryCdQK8BBkAAAAAAAAAAAAAAAAAKvkH9jRvYa+Q
        EvYAAAAASUVORK5CYII=
      ''')
      self.unmuted = tk.Image('photo', data = '''
        iVBORw0KGgoAAAANSUhEUgAAAHAAAABwCAYAAADG4PRLAAAACXBIWXMAAAsTAAALEwEAmpwYAAAF
        0ElEQVR4nO2d26sWVRjG3+xg5whNK6IvqLBziVlXWRd1EVFZWXoROV0FFZJ1Yxd5+gM6UFlSaQSd
        LYguMpX2lo4o0QErMGPvgiAsJS1Ls9N6mYTNh/O846xZh296fvDe7Wetl/fZs76ZtWatESGEEEII
        IYQQQgghhBBCCCGEEEIIIYQQ0hpHuFju4h8QJFPOcvG5YPNoYKbc5uJXsc2jgZlRZ8ikgZlyjosv
        5MDMi2XgJS6WuXjFxTwXh0bqd2AopP6QGdvAW1382dfnBhfHReg7e45ysVKaGRfDQM3v54p+h10c
        Hrj/rGk6ZMY08FKj71UuDg6cQ5YU0nzIjGng6TX6fzhwDlnRxpAZ08CDXLxTI4cbA+eRBW0NmbFv
        Yk518b2Rw3YXvQi5JKOQ9obM2AYqF0j1zcy++MDFIZHyiUaIITOFgcrlLn43crknYj7BqTuXOSgG
        KncauexwcVLknIJQSLghs00DZ0g5u/K+i0dcnFBDs8rIZ4VnTkmJMWS2ZeAcF3/1tfWDiymG7ngX
        34J8tM1pHnklI9RdZggDx7nYWtHeiIuTDf0NRk6vNswrGYXEGzLbMLBntPmJ2NNka4Be507PbJhb
        VFIMmW0YqMtWe412HzfaONtoY3nD3KKRashsw0BlWY22rzPaeB5o9ZEj2xWLQtINmW0ZqKPHBqNt
        vVk5ErRxoYu/gf52j/xqkbr4KQ1U9LHha6P9pUYbbwHt2575maQufmoDlfNd/Aba3yX4+XAW0OrN
        zOQWcqwkdfFzMFCZb/SxGGj1bnUH0BYt5bhfUhc/lIFXSbkMNOriTSl/qxA6CY2m/X50MR7onwXa
        oDMzqYsfwkB9yO6/sdgj5WQ04mqjn+uBFg2j3xj9epG6+CEM3FzxdzrzchqohS7efgr6eQloJwm+
        Gz0FaL1IXfy2DdTfI1TIj6Q0qoo7gFZ/59D7L18C7bVA50Xq4rdtoGKtns8C9Zjg4g+gvRhoVwDd
        vUDnRerihzDwLuPv9UpBV+Ew0M4HugVA9wTQeZG6+CEMVHNeMzToSloCdE8BHbqRWQd0XqQufggD
        lWOlvPWv0iwCNZkJdMNAdxHQbQI6L1IXP5SBygNAMwR05wLdCND1gG4U6LxIXfyQBqIrYjPQTQC6
        bQ11PwGdF6mLH9LAo4HmF6A7DOj2BNB5kbr4IQ08Bmh2At14oNsdQOdF6uKHNHAq0HAIzSiqWAg0
        Q0B3HtCNAF0P6EaBzovUxQ9loL7KgB4jFoKaNH2MQFc8HyNA9KMP8q8bGvTe5lKga/ogvxbovEhd
        /BAGWlNp+iIWmkpbD7Ro78P9QMepNBD9WJPZaC/fRMGT2ejKXQl0nMwGMRZrOelDab6cpNvL0HLS
        V0DL5SQQ/aAF3R6ohRr7GejnRaDVF5e4oNsw+ql6pWKGUYtrjH7QS743A90Wo18vUhc/hIHKlVIu
        4Yy4eEPqvdS0CfRhvdT0HNA+Y/TtRerihzLwQLnP6GMR0Oo+i51AO7elHPdL6uLnYKDuf0dbp3UL
        wUSgvwVodfPLpBZyrCR18VMbqMXdYrS/2GhjNdCu9swvGIV0Y3PLRqPtUSmHyCp0zRHdfc71yC84
        Xd9epsZYz28vAL3ut8h2e9k+urzB81GjDf0H7j/FcGw82TC3JBTSrS3WH4u9xXod0KuxZzTMLRmD
        dMiBzrqgQw6ss15uMnJ6uWFeyRmkY0ZmS/NjRr4D+WibUz3yyoJCBuOgn8ukvFredfGQ1Dvox1pr
        fNozp2zo4lFbdxu56AaYEyPnFJQuHXZ3hZRvl6Fc5kXMJyqFDPZxkzoZbh03+Z508LjJsXT5wNdt
        //1d5xnEI5eHjP51xmZm4Dyyo5DuHHr+YOAcsqULnx3QUwnHBc4ha3L/8Ices1V186JDK1ql/19R
        CD+9M/Dk/PGr6S4ek3LWRh/m+fGrCvj5uY7AD0B2AH6CtQPwI8iEEEIIIYQQQgghhBBCCCGEEEII
        IYQQkhP/AugVWTkwxeXIAAAAAElFTkSuQmCC
      ''')

  def render(self,oprofile, level, muted, msg = ''):
    print(self)
    print(type(self))
    self.icon['image'] = self.muted if muted else self.unmuted
    self.oprofile['text'] = oprofile
    # ~ self.volume.set(int(level*100))
    # ~ self.volume['state'] = 'disabled'
    self.message['text'] = msg

  def show_notice(oprofile, level, muged, msg = ''):
    piddir = os.getenv('XDG_RUNTIME_DIR')
    pid = None
    if piddir:
      pidfile = piddir + '/paui.pid'
      try:
        with open(pidfile,'r') as fp:
          pid = int(fp.read().strip())
      except (FileNotFoundError,IOError):
        print('not found')

      with open(pidfile,'w') as fp:
        fp.write('{pid}\n'.format(pid = os.getpid()))

    root = tk.Tk()
    root.option_add('*Font', "Helvetica 12")
    root.option_add('*oprofile.font', "Helvetica 14 bold")

    root.option_add('*Scale.orient', 'horizontal')
    root.option_add('*Scale.length', 320)
    root.option_add('*Scale.width', 16)
    root.wm_overrideredirect(True)
    root.wm_resizable(False,False)

    app = App(root)
    app.render(oprofile, level, muged, msg)
    app.after(DELAY, lambda app : app.quit(), app)
    if not pid is None:
      app.after_idle(lambda pid : os.kill(pid,signal.SIGTERM), pid)
    root.eval('tk::PlaceWindow . center')
    app.mainloop()

    if piddir: os.unlink(pidfile)

def argparse():
  '''
  Argument parser generator

  :return ArgumentParser: object instance for cli parsing
  '''
  cli = ArgumentParser(prog=COMMAND,
                        description='Pulse Audio operations')
  cli.set_defaults(func = None)
  subs = cli.add_subparsers()

  proctl = subs.add_parser('output', help='Toggle ouotput sink profile')
  proctl.set_defaults(func = pa_toggle_profile)

  volctl = subs.add_parser('vol', help='Volume control')
  volctl.add_argument('--up',dest='vctl',const=1,action='store_const',
                      help='Increase volume')
  volctl.add_argument('--dn','--down',dest='vctl',const=-1,action='store_const',
                      help='Decrease volume')
  volctl.add_argument('--mute',dest='vctl',const=0,action='store_const',
                      help='Toggle mute volume')
  volctl.set_defaults(func = pa_set_volume, vctl = None)

  return cli


def show_state(msg = ''):
  pros,active = pa_get_outputs()
  cvol = pa_volume_level()
  muted = pa_mute_state()

  # ~ notify2.init(COMMAND)
  # ~ n = notify2.Notification(,msg
                          # ~ '{card}|{profile}'.format(card=pros[newprofile].card.name, profile =  ))
  # ~ n.show()
  App.show_notice(pros[active].desc, cvol, muted, msg)


def pa_volume_level():
  cvol = 0.0
  cnt = 0
  for sink in pulse.sink_list():
    cvol += pulse.volume_get_all_chans(sink)
    cnt += 1
  if cnt == 0:
    print('No sinks found')
    sys.exit(25)
  cvol = cvol / cnt
  return cvol

def pa_mute_state():
  for sink in pulse.sink_list():
    if sink.mute == 0: return False
  return True


def pa_toggle_profile(toggle):
  '''
  Toggle PulseAudio output profile

  :param Namespace toggle: named tupple containing parsed arguments
  '''
  pros,active = pa_get_outputs()
  newprofile = (active + 1) % len(pros)

  print('Activating: {card},{profile}'.format(card=pros[newprofile].card.name, profile = pros[newprofile].desc ))
  pa_activate_profile(pros[newprofile])

  show_state('Toggle audio output')


def pa_set_volume(vopts):
  '''
  PulseAudio volume control

  :param Namespace toggle: named tupple containing parsed arguments
  '''
  if vopts.vctl is None:
    print('No volume control option specified')
    sys.exit(16)

  if vopts.vctl == 0:
    muted = pa_mute_state()
    muted = not muted

    for sink in pulse.sink_list():
      pulse.mute(sink, 1 if muted else 0)

    print('Muted' if muted else 'Unmuted')
    # ~ notify2.init(COMMAND)
    # ~ n = notify2.Notification('Volume','Muted' if muted else 'Unmuted')
    # ~ n.show()
    show_state('Muted' if muted else 'Unmuted')

  else:
    cvol = pa_volume_level()

    nvol = cvol + (vopts.vctl * 0.05)
    if nvol < 0.0:
      nvol = 0.0
    elif nvol > 1.0:
      nvol = 1.0

    for sink in pulse.sink_list():
      pulse.volume_set_all_chans(sink,nvol)

    print(nvol)
    show_state('Volume up' if vopts.vctl > 0 else 'Volume Down')

    # ~ notify2.init(COMMAND)
    # ~ n = notify2.Notification('Volume up' if vopts.vctl > 0 else 'Volume Down', 'Level: {p}%'.format(p = int(nvol*100)))
    # ~ n.show()

if __name__ == '__main__':
  cli = argparse()
  args = cli.parse_args()
  if args.func is None:
    cli.print_help()
    sys.exit(0)

  args.func(args)

# ~ print(active)
# ~ for p in pros:
  # ~ print(p)
# ~ print(newprofile)





    # ~ print('index: {i}'.format(i=c.index))
    # ~ print('  driver: {d}'.format(d=c.driver))
    # ~ print('  n_profiles: {np}'.format(np=c.n_profiles))
    # ~ print('  name: {n}'.format(n=c.name))
    # ~ print('  active_profile: {c}'.format(c=c.profile_active.name))
    # ~ print('                  {d}'.format(d=c.profile_active.description))
    # ~ profiles = c.profile_list
      # ~ print(p)








