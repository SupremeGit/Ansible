#!/bin/bash
# This script is run manually to install our soe from within docker image.
# Although most steps should be done with Dockerfile to make containers easier to rebuild etc.

hostname=`hostname`
LOGFILE="/root/${hostname}-run-soe.txt"
echo "" > "${LOGFILE}" 

msg="Huge Salty Balls"
echo "${hostname}-run-soe.sh"
echo "${msg}"

echo "${hostname}-run-soe.sh" 2>&1 >> "${LOGFILE}" 
echo "${msg}" 2>&1 >> "${LOGFILE}" 

netstat -aei 2>&1  
netstat -aei 2>&1 >> "${LOGFILE}" 

