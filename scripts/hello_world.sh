#!/bin/bash
#
# A script that is triggered by drone to examine the environment we run in.

echo "hostname: `hostname`"
echo "uptime: `uptime`"
echo "id: `id`"
echo "pwd: `pwd`"

echo "File system:"
/bin/df -h

echo "Network:"
/sbin/ip a

echo "File listing:"
/bin/ls -laF

