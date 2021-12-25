#
# Hack posts
#
from pprint import pprint

import glob
import time
import subprocess
import sys
import argparse
import re

HEADER=0
BODY=1
tagcloud = None

def today(t=None):
  if t is None: t = time.time()
  return time.strftime('%Y-%m-%d')

def read_file(fpath):
  with open(fpath,'r') as fp:
    return fp.read()

def write_file(fpath,txt):
  with open(fpath,'w') as fp:
    return fp.write(txt)

def load_post(text):
  msg = [ {}, [] ]
  state = BODY
  for line in text.split('\n'):
    if line.strip() == '---':
      if state == HEADER:
        state = BODY
        continue
      else: # state == BODY
        if len(msg[HEADER]) == 0:
          state = HEADER
        else:
          msg[BODY].append(line)
    elif state == HEADER:
      line = line.strip().split(':',1)
      if len(line) == 0: continue
      if line[0] == '': continue
      if len(line) == 1:
        msg[HEADER][line[0]] = None
      else:
        msg[HEADER][line[0]] = line[1].strip()
    else: # state == BODY
      msg[BODY].append(line);

  return msg

def dump_post(msg):
  txt = '---\n'
  for k in msg[HEADER]:
    if msg[HEADER][k] is None:
      txt += k + '\n'
    else:
      txt += k + ': ' + msg[HEADER][k] + '\n'
  txt += '---\n'
  txt += '\n'.join(msg[BODY])
  return txt

def check_git(msg, fpath):
  ret = subprocess.run(['git','status','--porcelain',fpath],capture_output=True)
  if ret.returncode == 0 and len(ret.stdout):
    msg[HEADER]['revised'] = today()

clean_re = re.compile(r'\W|^(?=\d)')
def clean(varStr):
  return clean_re.sub('_', varStr)

def tokenize(txt):
  if isinstance(txt,list): txt = ' '.join(txt)
  tokens = {}
  for t in txt.split():
    j = clean(t.lower().strip('_*.,'))
    tokens[j] = t
  # ~ pprint(tokens)
  return tokens

def read_tags(txt):
  if isinstance(txt,list): txt = ' '.join(txt)
  tags = {}
  for t in txt.split():
    j = t.split('=',1)
    if len(j) == 0: continue
    if len(j) == 1:
      if j[0] == '': continue
      j.append(j[0])
    tags[j[0]] = j[1]
  return tags

def analize_tags(minstr, minqs, articles):
  tagcloud = {}

  for pg in articles:
    sys.stderr.write('{pg}: '.format(pg=pg))
    txt = read_file(pg)
    msg = load_post(txt)
    tks = tokenize(' '.join(msg[BODY]))
    c = 0
    for t in tks:
      if len(t) < minstr: continue
      c += 1
      if t in tagcloud:
        tagcloud[t] += 1
      else:
        tagcloud[t] = 1
    sys.stderr.write('{words:,}\n'.format(words=c))

  for t in tagcloud:
    print('{count}:{tag}'.format(count=tagcloud[t],tag=t))

def autotag(msgbody):
  ret = {}
  tokens = tokenize(msgbody)
  for t in tagcloud:
    if t in tokens:
      ret[tagcloud[t]] = 1
  return sorted(ret.keys())


if __name__ == "__main__":
  cli = argparse.ArgumentParser(prog='hax',
                                description = 'Article parser')
  cli.add_argument('-t','--tags', help = 'Initial tag dictitionary',
                    action='store')
  cli.add_argument('articles',nargs='*',help='Articles to read')

  args = cli.parse_args()
  # ~ sys.stderr.write(str(args)+'\n')

  if args.tags: tagcloud = read_tags(read_file(args.tags))

  for pg in args.articles:
    itxt = read_file(pg)
    msg = load_post(itxt)
    check_git(msg,pg)
    if tagcloud:
      tags = autotag(msg[BODY])
      if len(tags): msg[HEADER]['tags'] = ', '.join(tags)
    otxt = dump_post(msg)

    if otxt != itxt:
      sys.stderr.write('{pg}: '.format(pg=pg))
      write_file(pg,otxt)
      sys.stderr.write('written {bytes:,}\n'.format(bytes=len(otxt)))

    # ~ pprint(tokenize(msg[BODY]))

  # ~ pprint(msg[HEADER])
  # ~ pprint(txt)
  # ~ pprint(dump_post(msg))

  # ~ analize_tags(4,5,args.articles)



  # ~ pprint()



# ~ for pg in sys.argv[1:]:
  # ~
  # ~ pprint(msg[HEADER])
  # ~ pprint(txt)
  # ~ pprint(dump_post(msg))

  # ~ msg = read_post(pg)
  # ~ pprint(msg)



  # ~ pprint(ret)
  # ~ print(pg)
  # ~ print('-----------------')
