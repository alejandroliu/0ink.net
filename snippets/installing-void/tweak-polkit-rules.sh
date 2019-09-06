#!/bin/sh
#
# Tweak PolKit RUles
#
# Use this command:
#	wget -O- https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/tweak-polkit-rules.sh | sh
# or
#	wget -O- https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/tweak-polkit-rules.sh | sudo sh
#
# In file `/etc/polkit-1/rules.d/10-udisks2.rules`:

tee /etc/polkit-1/rules.d/10-udisks2.rules <<'_EOF_'
// Allow udisks2 to mount devices without authentication
//
polkit.addRule(function(action, subject) {
  if (action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
	action.id == "org.freedesktop.udisks2.eject-media" ||
        action.id == "org.freedesktop.udisks2.filesystem-mount") {
    if (subject.isInGroup("storage")) {
      polkit.log("POSITIVE: isInGroup(storage)");
      return polkit.Result.YES;
    } else if (subject.local) {
      polkit.log("POSITIVE: local user");
      return polkit.Result.YES;
    } else {
      polkit.log("NEGATIVE: udisks rules");
    }

  }
});
_EOF_


# In file `/etc/polkit-1/rules.d/20-shutdown-reboot.rules`:
tee /etc/polkit-1/rules.d/20-shutdown-reboot.rules <<'_EOF_'
// Rule to allow reboots or shutdowns
//
polkit.addRule(function(action, subject) {
  if (action.id == "org.freedesktop.consolekit.system.stop" ||
	action.id == "org.freedesktop.consolekit.system.restart") {
    if (subject.isInGroup("wheel")) {
      polkit.log("POSITIVE: isInGroup(wheel)");
      return polkit.Result.YES;
    } else if (subject.local) {
      polkit.log("POSITIVE: local user");
      return polkit.Result.YES;
    } else {
      polkit.log("NEGATIVE: power rules");
    }
  }
});
_EOF_


