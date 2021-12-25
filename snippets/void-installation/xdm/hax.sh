#!/bin/sh
mnt=''
sed \
	-i-1 \
	-e 's!^DisplayManager.*session:.*$!DisplayManager*session:		/etc/X11/Xsession!' \
	-e 's!^DisplayManager._0.setup:.*$!DisplayManager._0.setup:	/etc/X11/xdm/Xsetup_0!' \
	-e 's!^DisplayManager._0.startup:.*$!DisplayManager._0.sstartup:	/etc/X11/xdm/GiveConsole!' \
	$mnt/etc/X11/xdm/xdm-config
	#> xdm-config
#diff -u --color $mnt/etc/X11/xdm/xdm-config xdm-config
