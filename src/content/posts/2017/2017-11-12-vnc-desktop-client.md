---
title: VNC desktop
tags: authentication, desktop, login, security
---

IDEA:

```
Client connects >
        < server sends version string (Use 3.3 only)
Client replies with actual verison string >
        < server sends security type; NONE
Client send ClientInit (shared flag) > 
        < sever sens ServerInit (server details) WxHxD Name
=== standard stuff ===
```
 
## 2 VERSIONS

- kiosk
  - unmodified vncviewer connects to a multiplexer screen
  - server (in inetd mode) first spawns a Xvnc (in inetd mode) which does a login authentication
    and finds an existing desktop or spawns a new one
    saves the port and exists
  - server then connects to the new desktop port and does the VNC handshake.  Sends client
    Desktop change and name change messages
  - Forwards everything...
- command
  - User points command to a server.
  - Script selects a new port.
  - Ssh to server, look for vnc session, or spawn new one.
  - netcat to vnc session.
  - Listen to to new port, and netcat to ssh.
  - vncviewer to netcat port.

We use only v3.3 because we don't want to mess with security types.  Security should be handled by SSH tunnel.


Check if user can login

- [checkpassword](https://wiki.dovecot.org/AuthDatabase/CheckPassword)
- [unix pam](https://github.com/jonabbey/panda-imap/blob/master/src/osdep/unix/ckp_pam.c)
- [authpam](https://github.com/svarshavchik/courier/blob/master/courier-authlib/authpam.c)
- [busybox login](https://github.com/mozilla-b2g/busybox/blob/master/loginutils/login.c)
- [citadel auth](https://github.com/mingodad/citadel/blob/master/citadel/auth.c)
- [PamModules](http://www.linuxdevcenter.com/pub/a/linux/2002/04/04/PamModules.html)


