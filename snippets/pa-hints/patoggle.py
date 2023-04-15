#!/usr/bin/env python3
# xbps-install python3-notify2 python3-pulsectl

import pulsectl
import notify2
from collections import namedtuple

PaCard = namedtuple('PaCard','id name')
'''
PulseAudio card definition
'''
PaOutputProfile = namedtuple('PaOutputProfile', 'card name desc')
'''
PulseAudio Output Profile
'''

pulse = pulsectl.Pulse('patoggle2')
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

pros,active = pa_get_outputs()
newprofile = (active + 1) % len(pros)

# ~ print(active)
# ~ for p in pros:
  # ~ print(p)
# ~ print(newprofile)

print('Activating: {card},{profile}'.format(card=pros[newprofile].card.name, profile = pros[newprofile].desc ))
pa_activate_profile(pros[newprofile])

notify2.init('patoggle')
n = notify2.Notification('Toggle audio output',
                        '{card}|{profile}'.format(card=pros[newprofile].card.name, profile = pros[newprofile].desc ))
n.show()

    # ~ print('index: {i}'.format(i=c.index))
    # ~ print('  driver: {d}'.format(d=c.driver))
    # ~ print('  n_profiles: {np}'.format(np=c.n_profiles))
    # ~ print('  name: {n}'.format(n=c.name))
    # ~ print('  active_profile: {c}'.format(c=c.profile_active.name))
    # ~ print('                  {d}'.format(d=c.profile_active.description))
    # ~ profiles = c.profile_list
      # ~ print(p)




