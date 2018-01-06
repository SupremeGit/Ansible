# .bashrc

#echo "Executing" ~/.bashrc
#echo "PWD="`pwd`

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
#these are in .bashrc_aliases but lets make sure we always have them here:

#ensure we have these:
alias h=history
alias cbrc="cat ~/.bashrc"
alias ebrc="emacs ~/.bashrc"
alias sbrc="source ~/.bashrc"
alias vbrc="vim ~/.bashrc"
alias vibrc="vi ~/.bashrc"
alias sba="source ~/.bashrc_aliases"

PASSWD_FILE=~/.bashrc_passwords
for i in ~/.bashrc_aliases ~/.vnc/xstartup-common.sh "${PASSWD_FILE}" ; do 
    if [[ -e "${i}" ]] ; then 
	#echo "Sourcing ${i}"
	source "${i}" 
    fi
done
							       
#fix dolphin bug (buttons have no icons) when su - or ssh to root:
#export XDG_CURRENT_DESKTOP="kde:xfce"
#export XDG_RUNTIME_DIR=/var/run/

#disable x screen blanking:
xset s off > /dev/null 2>&1

#re-enable ctrl-alt-backspace to zap x server:
setxkbmap -option -option terminate:ctrl_alt_bksp > /dev/null 2>&1

export PATH=${PATH}:/usr/local/bin/jss

#echo "PWD="`pwd`
#echo "Finished" ~/.bashrc
