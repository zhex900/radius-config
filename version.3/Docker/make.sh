#!/bin/bash

FR=fr3

# 1. build complete freeradius3 image
echo "Step 1. Build complete freeradius3 image."
docker build -t zhex900/$FR:fat .

# 2. make stripped imaged
echo "Step 1. Completed!"
echo "Step 2. Strip the freeradius3 images."
sudo ./strip-docker-image -i zhex900/$FR:fat -t zhex900/$FR:stripped -p curl -p perl -p freeradius -p vim -f /etc/vim -f /etc/freeradius -f /bin/chmod -f /bin/tar -f /bin/mv -f /bin/date -f /bin/cp -f /bin/bash -f /bin/ls -f /bin/ps -f '/lib/*/libnss*' -f /usr/share/freeradius -f /etc/pam.d/radiusd -f /usr/sbin/freeradius -f /usr/lib/freeradius -f /usr/share/lintian  -f /bin/bash -f /bin/ls -f /bin/ps -f /bin/cat -f /usr/bin/vi  -f '/usr/lib/x86_64-linux-gnu/*sql*'  -f /lib/x86_64-linux-gnu/libgcc_s.so.1 -f /bin/chown -f /usr/local/lib/perl/5.18.2 -f /usr/local/share/perl/5.18.2 -f /usr/lib/perl5 -f /usr/share/perl5 -f /usr/lib/perl/5.18 -f /usr/share/perl/5.18 -f /var/run -f /run -f /tmp -f /bin/rm -f /etc/nsswitch.conf -f /etc/mysql -f /etc/group -f /etc/hosts -f /etc/hostname -f /etc/perl -f /etc/passwd -f /etc/environment -f /etc/resolv.conf -f /bin/mkdir -f /bin/sleep -f /bin/sh -f  /usr/bin/perl -f /etc/ssl -f /usr/share/ca-certificates -f /etc/timezone

# 3. add start-up script to image
echo "Step 2. Completed!"
echo "Step 3. Add start-up script"
cd thin && docker build -t zhex900/$FR:thin .
