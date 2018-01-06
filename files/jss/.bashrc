# .bashrc

#echo "Executing ~/.bashrc"

# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

#----------------------------------------------------------------------------
#misc:

#ll /var/run/nologin
#systemctl restart systemd-user-sessions.service > /dev/null
#emacs /etc/systemd/system/systemd-user-sessions.service.d/systemd-tmpfiles-setup.conf
#rm -f /var/run/nologin > /dev/null

#fix console paging etc:
export PAGER="less -MisX"
export MANPAGER="less -MisX"
#export SYSTEMD_PAGER=less
export SYSTEMD_LESS="FRXMK"
alias less="less -MisX"
export EDITOR=emacs
export ANSIBLE_NOCOWS=1

shopt -s histappend
HISTFILESIZE=1000000
HISTSIZE=1000000
#HISTCONTROL=ignoreboth   # ignorespace & ignoredups
#HISTCONTROL=ignorespace  # ignore lines begingging with a space
HISTCONTROL=ignoredups:ignorespace:erasedups
HISTIGNORE='ls:bg:fg:history'
HISTTIMEFORMAT='%F %T '
PROMPT_COMMAND='history -a'
shopt -u huponexit
shopt -s checkwinsize
PS1='[\u@\h \D{%m-%d %T} \W]\$ '

export LS_OPTIONS='--color=auto'
eval "`dircolors`"

#----------------------------------------------------------------------------
#basic, general purpose aliases:
#these are in bashrc_aliases but lets make sure we always have them here:

#ensure we have these:
alias h=history
alias cbrc="cat ~/.bashrc"
alias ebrc="emacs ~/.bashrc"
alias sbrc="source ~/.bashrc"
alias vbrc="vim ~/.bashrc"
alias vibrc="vi ~/.bashrc"
alias sba="source ~/.bashrc_aliases"
source ~/.bashrc_aliases
source ~/.bashrc_passwords

#fix dolphin bug (buttons have no icons) when su - or ssh to root:
export XDG_CURRENT_DESKTOP=kde
#export XDG_RUNTIME_DIR=/var/run/

#disable x screen blanking:
xset s off > /dev/null 2>&1
setxkbmap -option -option terminate:ctrl_alt_bksp > /dev/null 2>&1

#----------------------------------------------------------------------------
#Dev

#oracle jdk8:
#export JAVA_HOME=/usr/local/java/jdk1.8.0_40/

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.144-5.b01.fc26.x86_64/

#Android IDE says openJDK has performance/stutter issues and recommends oracle.
#export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/

#export PATH=${PATH}:/usr/local/java/android-sdk-linux/tools
#export PATH=${PATH}:/usr/local/java/android-sdk-linux/platform-tools
#export PATH=${PATH}:/opt/android-sdk-linux/tools
#export PATH=${PATH}:/opt/android-sdk-linux/platform-tools
export PATH=${PATH}:/usr/local/bin/jss

#VTK vars set in /etc/profile.d/vtk.sh

#----------------------------------------------------------------------------
#ansible:
export ANSIBLE_DEBUG=0
#export ANSIBLE_DEBUG=1

function fix_kde () {
    #for kss kde, not being done automatically for some reason:
    mkdir -p /var/run/user/1000
    chown jss /var/run/user/1000
    chmod 0700 /var/run/user/1000
}
#if [[ "m$USER" == "mroot" ]] ; then
#    fix_kde
#fi


#----------------------------------------------------------------------------
#Notes:
#----------------------------------------------------------------------------

#docker:
#config file: ~/.docker/config.json
#shit stored in /var/lib/docker
##cd /data-ssd/data/development/os/docker/

#unbelievable:
#Dec 01 08:09:44 Il-Duce dockerd-current[8684]: time="2017-12-01T08:09:44.914146050+10:30" level=warning msg="overlay2: the backing xfs filesystem is formatted without d_type support, which leads to incorrect behavior. Reformat the filesystem with ftype=1 to enable d_type support. Running without d_type support will no longer be supported in Docker 1.16."
#Dec 01 08:09:44 Il-Duce dockerd-current[8684]: Error starting daemon: error initializing graphdriver: /data-ssd/data/var/lib/docker contains several valid graphdrivers: devicemapper, overlay2; Please cleanup or explicitly choose storage driver (-s <DRIVER>)

#gedit ~/.kde/share/config/kwalletrc
#Once the file opens, hit Ctrl+End to go to the bottom of the file, hit Enter a couple of times (so there will be a blank paragraph between the last entry and the test you’ll be pasting), and add the following:
#[Auto Deny]
#kdewallet=Chromium
#(substitute “Google Chrome” instead of “Chromium” if using the former)
#Save and exit the file. Log out and back in again for the changes to take effect, or simply enter the following into the terminal:
#killall -9 kwalletd

#systemctl disable dnf-makecache.timer
#systemctl mask dnf-makecache.timer
#systemctl mask dnf-makecache

#splunk
#/opt/splunk/bin/splunk enable boot-start -user splunk
#chkconfig --list | grep splunk
#service splunk start
#service splunk stop

#client:
#/opt/splunk/bin/splunk set deploy-poll il-duce:8089
#/opt/splunk/bin/splunk restart

#web management interface:
#http://127.0.0.1:8000/

#loginctl:
#When I just log out, I can manually stop the systemd user session using:
#loginctl kill-user/kill-session
#(I am not sure which one I used last time), which will terminate user bus and all the other services from that session.

#Journalctl:
#-x, --catalog     #Augment log lines with explanation texts from the message catalog.
#-e, --pager-end   #Jump to end of pager (less). 1000lines paged by default. Use -n10000 or -nall for more
#-r, --reverse     # Reverse output so that the newest entries are displayed first.

#-t, --identifier=SYSLOG_IDENTIFIER   #Show messages for the specified syslog identifier SYSLOG_IDENTIFIER.
#-u, --unit=UNIT|PATTERN              #Show messages for the specified systemd unit UNIT
#--user-unit=                         #Show messages for the specified user session unit.
#-S, --since=, -U, --until=           #Showing entries on or newer than specified date, or on or older
#--system, --user  #Show messages from system services & kernel (with --system).
# --user           #Show messages from service of current user (with --user). If neither is specified, show all messages that the user can see.

#-b [ID][±offset], --boot=[ID][±offset]  # Show messages from a specific boot. This will add a match for "_BOOT_ID=".
#--list-boots      #Show tabular list of boot numbers (relative to current boot), their IDs, and timestamps of first & last message
#-k, --dmesg       #Show only kernel messages. This implies -b and adds the match "_TRANSPORT=kernel".
#--disk-usage      #Shows the current disk usage of all journal files.
#--verify          #Check the journal file for internal consistency.
#--rotate          #Asks the journal daemon to rotate journal files.

#If you enable the systemd debug shell and use it to run "systemd-cgls" during this 90 second wait, you'll probably see that all processes in the dbus.service cgroup below user@1000.service were terminated by systemd sending the TERM signal, except for some daemon (for example it might be kglobalaccel5 in Comment #36) or a small number of daemons. If so, the cause of your slow shutdown is very likely to be a bug in those daemons - they do not die when sent the TERM signal - similar to the kglobalaccel5 bug described in Comment #36.

#Early Debug Shell
#You can enable shell access to be available very early in the startup process to fall back on and diagnose systemd related boot up issues with various systemctl commands. Enable it using:
#
#systemctl enable debug-shell.service
#or by specifying
#systemd.debug-shell=1
#on the kernel command line.
#Tip: If you find yourself in a situation where you cannot use systemctl to communicate with a running systemd (e.g. when setting this up from a different booted system), you can avoid communication with the manager by specifying --root=:
#
#systemctl --root=/ enable debug-shell.service
#Once enabled, the next time you boot you will be able to switch to tty9 using CTRL+ALT+F9 and have a root shell there available from an early point in the booting process. You can use the shell for checking the status of services, reading logs, looking for stuck jobs with systemctl list-jobs, etc.
#
#Warning: Use this shell only for debugging! Do not forget to disable systemd-debug-shell.service after you've finished debugging your boot problems. Leaving the root shell always available would be a security risk.

#When you have systemd running to the extent that it can provide you with a shell, please use it to extract useful information for debugging. Boot with these parameters on the kernel command line:

#systemd.log_level=debug systemd.log_target=kmsg log_buf_len=1M printk.devkmsg=on
#in order to increase the verbosity of systemd, to let systemd write its logs to the kernel log buffer, to increase the size of the kernel log buffer, and to prevent the kernel from discarding messages. After reaching the shell, look at the log:

#To check for possibly stuck jobs use:
#systemctl list-jobs
#The jobs that are listed as "running" are the ones that must complete before the "waiting" ones will be allowed to start executing.


#Shutdown Completes Eventually
#If normal reboot or poweroff work, but take a suspiciously long time, then
#boot with the debug options:
#systemd.log_level=debug systemd.log_target=kmsg log_buf_len=1M printk.devkmsg=on enforcing=0
#save the following script as /usr/lib/systemd/system-shutdown/debug.sh and make it executable:

##!/bin/sh
#mount -o remount,rw /
#dmesg > /shutdown-log.txt
#mount -o remount,ro /
#reboot
#
#Look for timeouts logged in the resulting file shutdown-log.txt and/or attach it to a bugreport.
#Immediately before executing the actual system halt/poweroff/reboot/kexec systemd-shutdown will run all executables in /usr/lib/systemd/system-shutdown/ and pass one arguments to them: either "halt", "poweroff", "reboot" or "kexec", depending on the chosen action. All executables in this directory are executed in parallel, and execution of the action is not continued before all executables finished.
#Could try putting under etc as suggested below, but from above, doesnt sound like it will work, need to use /usr
#Additionally, as I mentioned in my comment, you should put custom scripts into /etc/systemd/system/. The /usr/lib/systemd/system/ directory is meant to be used for system-provided scripts.

#disable razer mouse acceleration
#xset m 1/2 0
#increasing last digit lowers sensitivity. 
#xinput --set-prop 8 153 1 0 0 0 1 0 0 0 5 #this is not too bad

#xinput list
#xinput list-props 9
#xinput set-prop 'Microsoft Microsoft 3-Button Mouse with IntelliEye(TM)' 'Coordinate Transformation Matrix' 1 0 0 0 1 0 0 0 1

