#!/bin/bash
# This script runs on launch, command is specified in the dockerfile 

LOGFILE="/root/run-soe.txt"

echo "run-soe.sh"
echo "run-soe.sh" 2>&1 > "${LOGFILE}" 

#dnf --assumeyes install openssh-server

#need to install a process manager like monit or supervisord before we can run sshd
#running sshd is generally not good in docker but for testing purposes:
#systemctl enable sshd
#systemctl start sshd
#systemctl status sshd

netstat -aei 2>&1  
netstat -aei 2>&1 > "${LOGFILE}" 

