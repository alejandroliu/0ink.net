#!/bin/sh
#
# Configure logs
#
# Use this command:
#	wget -O- https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/setup-socklog.sh | sh
# or
#	wget -O- https://github.com/alejandroliu/0ink.net/raw/master/snippets/installing-void/setup-socklog.sh | sudo sh
#
# Install package (if not done so already...)
xbps-install -S socklog-void

# Optional
# usermod -aG socklog <your username>

# Because I like to have just a single directory for everything and use
# `grep`, I do the following:

rm -rf /var/log/socklog/?*
mkdir /var/log/socklog/everything
ln -s socklog/everything/current /var/log/messages.log

# Create the file `/var/log/socklog/everything/config` with these
# contents:
tee /var/log/socklog/everything/config <<_EOF_
+*
u172.17.1.8:514
_EOF_

#
# Enable daemons...
#
ln -s /etc/sv/socklog-unix /var/service/
ln -s /etc/sv/nanoklogd /var/service/

# Reload `svlogd` (if it was already running)

killall -1 svlogd
