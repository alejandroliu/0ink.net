#/usr/bin/env python
from bottle import route, run, request, response, abort, redirect
import sys
import uuid

SIGNATURE = uuid.uuid4()
COOKIE = 'demo-cookie'

sessions = {}

def check_login(username,password):
  if username == password:
    return True
  return False

def is_active_session():
  sid = request.get_cookie(COOKIE, secret=SIGNATURE)
  if not sid:
    return None
  if sid in sessions:
    return sid
  else:
    return None    

@route('/hello')
def show_headers():
  hdrs = dict(request.headers)
  import pprint
  return "Got it\n<pre>\n"+pprint.pformat(hdrs,2)+"\n</pre>\n"

@route('/login/', method='GET')
def user_login():
  sid = is_active_session()
  if sid:
    return 'Logged in as %s' % sessions[sid]

  return '''
    <form method="post">
     Username: <input name="username" type="text" /><br/>
     Password: <input name="password" type="password" /><br/>
     <input value="Login" type="submit" />
    </form>'''

@route('/login/',method='POST')
def do_login():
  username = request.forms.get('username')
  password = request.forms.get('password')
  if 'url' in request.query:
    url = request.query.url
  else:
    url = None

  if check_login(username,password):
    sid = uuid.uuid4
    sessions[sid] = username
    response.set_cookie(COOKIE, sid, secret=SIGNATURE, path="/", httponly=True)
    if url:
      redirect(url)
    else:
      return "Welcome %s" % username
  else:
    return "Login Failed"

@route('/auth')
def auth():
  sid = is_active_session()
  if sid:
    response.set_header('X-Username', sessions[sid])
    response.set_header('X-Session', str(sid))
    return 'OK ' + str(sid)
  else:
    abort(401,"Unathenticated")

run(host='0.0.0.0', port=8080)
