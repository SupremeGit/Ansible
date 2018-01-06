#!/bin/sh

#echo "  Executing" ~/.vnc/xstartup-common.sh

function plasma_env () {
    #Override vars from: /etc/xdg/plasma-workspace/env/env.sh

    #XDG_CONFIG_DIRS looks important, has tonnes of crap in it:
    # XDG_CONFIG_DIRS
    if [ -z "${XDG_CONFIG_DIRS}" ] ; then
	XDG_CONFIG_DIRS=/etc/xdg:/usr/share/kde-settings/kde-profile/default/xdg
	export XDG_CONFIG_DIRS
    fi
    
    # XDG_DATA_DIRS
    if [ -z "${XDG_DATA_DIRS}" ] ; then
	XDG_DATA_DIRS=/usr/share/kde-settings/kde-profile/default/share:/usr/local/share:/usr/share
	#XDG_DATA_DIRS=/home/jss/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share
	export XDG_DATA_DIRS
    fi
    
    # XDG_MENU_PREFIX
    if [ -z "${XDG_MENU_PREFIX}" ] ; then
	XDG_MENU_PREFIX="kf5-"
	export XDG_MENU_PREFIX
    fi
}

function override_xdg_dirs () {
    #override other xdg dirs:
    
    export XDG_CURRENT_DESKTOP=kde

    #export XDG_RUNTIME_DIR=/run/user/1000      #no need to set this if user sessions working
    #export XDG_RUNTIME_DIR=/tmp/runtime-jss/   #this seems vital. /run/user/1000 no good when we dont have session

}

function start_kde_old () {
    WM="startkde"
    WMPATH="/usr/bin /opt/bin /usr/local/bin /usr/X11R6/bin"

    #env > ~/env-vnc-kde-old.txt
    
    for p in $WMPATH ; do
            [ -x $p/$WM ] && exec $p/$WM
    done
}

function start_kde_new () {
    GSESSION="$(type -p gnome-session)"
    MSESSION="$(type -p mate-session)"
    STARTKDE="$(type -p startkde)"
    STARTLXDE="$(type -p startlxde)"

    #env > ~/.vnc/env-vnc-kde-new.txt
    
    #kde may refuse to run in vnc if its running on real displays already.
    #exec startkde
    exec ${STARTKDE}
}

#unset SESSION_MANAGER
#unset DBUS_SESSION_BUS_ADDRESS

#source /etc/profile
##pulls in /etc/profile.d/kde.sh and /etc/profile.d/qt.sh
##ensure the following vars are set when we start kde apps from xfce panel etc:
##KDEDIRS=/usr
##QTblah

source /etc/xdg/plasma-workspace/env/env.sh #>> "${LOG}" 2>&1
#plasma_env      #set same vars but we can override them
#sets:
#XDG_CONFIG_DIRS=/etc/xdg:/usr/share/kde-settings/kde-profile/default/xdg
#XDG_DATA_DIRS=/usr/share/kde-settings/kde-profile/default/share:/usr/local/share:/usr/share
#XDG_MENU_PREFIX="kf5-"

override_xdg_dirs
#may be used to override vars eg:
#XDG_CURRENT_DESKTOP=kde
#XDG_RUNTIME_DIR

env | sort > ~/"xstartup-common.env.txt" 2>&1

#echo "  Finished" ~/.vnc/xstartup-common.sh
