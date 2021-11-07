#!/bin/bash
#
# A script that is triggered by drone to examine the environment we run in.

echo "hostname: `hostname`"
echo "uptime: `uptime`"
echo "File system:"
df -h

echo "Network:"
ip a

