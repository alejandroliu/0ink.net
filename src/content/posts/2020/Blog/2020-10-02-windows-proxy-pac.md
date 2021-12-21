---
title: Getting the current proxy pac configuration
date: 2020-10-02
---


This is done using [tcl][tcl] for convenience.  If you
do not have it installed you can download [freewrap][freewrap]
executable and rename `freewrap.exe` to `wish.exe` or `freewrapTCLSH.exe` to
`tclsh.exe`.

```
Registry Key : HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\
REG_SZ AutoConfigURL = https://<your url>/proxy.pac
REG_DWORD ProxyEnable = 0
```

This is the [tcl][tcl] script:

```tcl
package require http

set pacURL [registry get {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings} AutoConfigURL]
puts $pacURL

set conn [::http::geturl $pacURL]
::http::wait $conn
puts [::http::data $conn]

```

[tcl]: https://www.tcl.tk/
[freewrap]: http://freewrap.sourceforge.net/
