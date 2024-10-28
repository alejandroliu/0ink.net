#!python3
#
# HotKey configuration
#
from evdev import ecodes
import shlex
import sys


def process_mapping(inp: list, maps: list):
  LR_Modifiers = ('CTRL', 'SHIFT', 'ALT', 'META' )
  Leds = ('CAPSL', 'NUML')

  for led in Leds:
    if not ((led in inp) or (f'!{led}' in inp)):
      process_mapping([*inp, led],maps)
      process_mapping([*inp, f'!{led}'],maps)
      return
  for mod in LR_Modifiers:
    if mod in inp:
      inp.remove(mod)
      process_mapping([*inp,f'LEFT{mod}'],maps)
      process_mapping([*inp,f'RIGHT{mod}'],maps)
      return

  # Validate tokens
  for led in Leds:
    nled = f'!{led}'
    if nled in inp: inp.remove(nled)

  key = None
  for t in inp:
    if t.startswith('LEFT') and t[4:] in LR_Modifiers: continue
    if t.startswith('RIGHT') and t[5:] in LR_Modifiers: continue
    if t in Leds: continue
    if not t.startswith('KEY_'):
      raise RuntimeError(f'Unknown keycode {t}')
    keycode = ecodes.ecodes[t]
    if key is None:
      key = t
    else:
      raise RuntimeError('Only single key supported')
  if key is None:
    raise RuntimeError('No key specified')

  inp.remove(key)
  maps.append((key,sorted(inp)))

  # ~ print(key,sorted(inp))

def help_key_str(txt: str):
  return ','.join(sorted(['key_'+word[4:] if word.startswith('KEY_') else word for word in txt.split(',')]))

def read_hk_cfg(fname: str):
  '''Read Hotkey configuration file

  :param str fname: Configuration file name
  '''
  alt_maps = []
  actions = []
  hotkeys = {}
  helpkeys = []
  helpcmds = {}

  with open(fname,'r') as fp:
    lc = 0
    for ln in fp.readlines():
      lc += 1
      ln = shlex.split(ln, True)
      if len(ln) == 0: continue
      if ln[0][-1] == ':':
        # Process map
        try:
          process_mapping(ln[0][:-1].split(','),alt_maps)
          helpkeys.append(help_key_str(ln[0][:-1]))
        except (RuntimeError, KeyError) as e:
          sys.stderr.write(f'Error:{fname},{lc}: hotkey mapping {e}\n')

        ln = ln[1:]
      if len(ln) == 0: continue

      if len(alt_maps) == 0: continue # No maps to speak of
      action = len(actions)
      actions.append(ln)

      hc = shlex.join(ln)
      if hc in helpcmds:
        helpcmds.append(*helpkeys)
      else:
        helpcmds[hc] = helpkeys

      for hk,mlst in alt_maps:
        if not hk in hotkeys:
          hotkeys[hk] = {}
        mods = ','.join(mlst)
        hotkeys[hk][mods] = action
      alt_maps = []
      helpkeys = []

  return hotkeys,actions, helpcmds

if __name__ == '__main__':
  hk,act,hlp = read_hk_cfg('config.txt')
  print(hk)
  print(act)
  print(hlp)
