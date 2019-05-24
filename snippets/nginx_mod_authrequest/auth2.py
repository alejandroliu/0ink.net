#/usr/bin/env python
from bottle import route, run, request, response, abort, redirect
import base64

def check_login(username,password):
  if username == password:
    return True
  return False

def authorize(basic_str):
  if not basic_str:
    return False
  auth = basic_str.split()
  if auth[0] != 'Basic':
    # We only support basic authentication
    return False
  auth = base64.b64decode(auth[1])
  auth = auth.split(':',2)
  if len(auth) != 2:
    # Unable to decode username password...
    return False
  
  if check_login(auth[0],auth[1]):
    response.set_header('X-Username', auth[0])
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

  response.set_header('WWW-Authenticate', 'Basic realm="DEMO REALM"')
  response.status = 401
  return 'Unauthenticated'

run(host='0.0.0.0', port=8080)
