#/usr/bin/env python
from bottle import route, run, request, response, abort, redirect
import base64
import hashlib
import random
import shlex

REALM = 'Demo Realm'

def md5sum(x):
  return hashlib.md5(x).hexdigest()

def gen_noise(len = 16):
  letters = '0123456789abcdef'
  salt = ''
  for x in range(len):
    salt = salt + random.choice(letters)
  return salt

def authorize(auth):
  if not auth:
    return False
  auth = shlex.split(auth)
  if len(auth) < 2 or auth[0] != 'Digest':
    return False

  req = {}
  for x in auth:
    if x[-1:] == ',':
      x = x[:-1]
    x = x.split('=',2)
    if len(x) == 0:
      continue
    elif len(x) == 1:
      req[x[0].lower()] = True
    else:
      req[x[0].lower()] = x[1]

  # make sure that all fields are there...
  for x in ['username','realm','nonce','uri','response']:
    if not x in req:
      print('Missing "%s" in response' % x)

  method = request.headers.get('X-Origin-Method')
  if not method:
    method = 'GET'

  ha1 = md5sum('%s:%s:%s' % (req['username'],req['realm'],req['username']))
  ha2 = md5sum('%s:%s' % (method, req['uri']))
  resp = md5sum('%s:%s:%s' % ( ha1, req['nonce'], ha2))

  #print(req)
  #print("calc: %s\nrecv: %s\n" % (resp, req['response']))

  if resp == req['response']:  
    response.set_header('X-Username', req['username'])
    return True

  return False  


@route('/hello')
def show_headers():
  hdrs = dict(request.headers)
  import pprint
  return "Got it\n<pre>\n"+pprint.pformat(hdrs,2)+"\n</pre>\n"

@route('/auth')
def auth():
  if authorize(request.headers.get('Authorization')):
    return 'Yes, go in'

  nonce = gen_noise(32)
  opaque = gen_noise(32)
  
  #print("nonce=%s\nopaque=%s\n" % (nonce, opaque))
  response.set_header('WWW-Authenticate', 'Digest realm="%s", nonce="%s", opaque="%s"' % (REALM, nonce, opaque))
  response.status = 401
  return 'Unauthenticated'

run(host='0.0.0.0', port=8080)
