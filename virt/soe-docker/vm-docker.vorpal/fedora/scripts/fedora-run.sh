#!/bin/bash
# This script runs on launch, command is specified in the dockerfile 

LOGFILE="/root/${hostname}-run.log.txt"
hostname=`hostname`

echo "${hostname}-run.sh"
echo "${hostname}-run.sh" 2>&1 > "${LOGFILE}" 
 
#dnf --assumeyes install net-tools
#dnf --assumeyes install openssh-server

#need to install a process manager like monit or supervisord before we can run sshd
#running sshd is generally not good in docker but for testing purposes:
#systemctl enable sshd
#systemctl start sshd
#systemctl status sshd

netstat -aei 2>&1  
netstat -aei 2>&1 >> "${LOGFILE}" 

