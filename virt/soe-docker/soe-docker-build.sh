#!/bin/bash
scriptname="soe-docker-build.sh"
# soe-docker-build.sh - script to sequence some Docker ops using:
#    soe-docker-vm-control.sh to: maniupulate docker vms
#    todo: several ansible playbooks to connect & install soe on hosts 
#
# By default: build the docker image defined by Dockerfile and update 01, working, tags.
# Also run the ${hostname}-run-soe.sh script on each container.
#
# Can call this script like:
#   soe-docker-build.sh --vms "centos7 fedora"
#
#   soe-docker-vm-control script is alao called like:
#     soe-docker-vm-control.sh status  --vms "centos7 fedora temp foo bar ubuntu ubuntu_server"
#     If present, --vms "foo bar" must be the last parameter

#Typical usage:
#  docker pull fedora
#  https://hub.docker.com/_/fedora/
#    follow links to GitHub to get Dockerfile & fedora-27-x86_64-20171110.tar.xz
#  tweak dockerfile
#  Use this script to build the base image (01) and update working & current tags.
#  Run shell in container:
#    Define:
#      function docker-run-interactive () { snapshot="${1}" ; shift ; docker run --tty --interactive --name "fedora" --hostname "fedora" --net docker-net --ip 192.168.130.100 "${snapshot}" /bin/bash $@ ; }
#      alias docker-container-restart="docker start -ai"
#    Then you can:
#    docker-run-interactive soe.vorpal_fedora:current
#    docker-container-restart fedora
#
#Todo:
#setup networks instead of usign manual aliases:
#alias docker-net="docker network create --driver bridge --subnet=192.168.130.0/24 docker-net"
#alias docker-net-rm="docker network rm docker-net"


#Docker system config is at:
#  config file: ~/.docker/config.json
#  images stored in: /var/lib/docker
#  cd /data-ssd/data/development/os/docker/

#soe-vm-control.sh operates on a group of vms defined from a libvirt template:
#  available operations: create, define, undefine, define, reimage, refresh, start, destroy, save. restore, shutdown, reboot, reset
TOOL_DIR="/data-ssd/data/development/src/github/ansible-soe/virt"
soe_vm_control_script="${TOOL_DIR}/soe-docker/soe-docker-vm-control.sh"
domain="docker.vorpal"       #vm "domain" to use when creating vms
source "${TOOL_DIR}/soe-ansible/soe-ansible.sh"     #source functions to run our ansible soe playbooks
SSHD_DELAY=15             #extra delay to wait for ssh.

#vms to operate on:
#def_vm_names="centos7 fedora ubuntu ubuntu_server temp foo bar"
#def_vm_names="fedora ubuntu_server temp"
#def_vm_names="fedora temp"
def_vm_names="fedora"
vm_names=""

function msg_start    () { echo ; echo "Started"   ; date +%H-%M-%S ; echo ; }
function msg_finished () { echo ; echo "Finished:" ; date +%H-%M-%S ; echo ; }
function set-x-on     () { set -x ; }
function set-x-off    () { set +x ; }

function soe-set-vm_names () {
    export vm_names="${def_vm_names}"
    vm_fq_names=""
    for i in ${vm_names} ; do 
	#echo "Adding ${i} to vm_fq_names=${vm_fq_names}"
	###vm_fq_names+="${i}.${domain}."
	vm_fq_names+="${i}.${domain} "
	#echo "vm_fq_names=${vm_fq_names}"
    done
    #vm_fq_names=${vm_fq_names%*.} #strip trailing ,
    vm_fq_names=${vm_fq_names%* } #strip trailing " "
    export vm_fq_names
}
function usage () { echo "Usage: Sorry not done yet." ; exit ; }

function process_args () {
    #call like: process_args "$@"
    local ok=1
    while (( "$#" )); do
	case ${1} in          #switches for this shell script begin with '--'
            -h | help)        usage;;
            -d | --debug )    export debug=1; export DEBUG=echo ; echo -e "\nDebug mode on.";;
            --vms)            shift ; export def_vm_names="$@" ; soe-set-vm_names ; echo "VMs = ${vm_names}" ; shift $# ;; #shift to use up all args
            *)                ok=0 ; echo "Unrecognised option: ${1}" ;  usage ;;
	esac;
	shift
    done
    if [ $ok -eq 0 ] ; then echo "Halp. Something isn't right with the command arguments. Exiting." ; usage ; fi
    echo
}

function soe-vm-control () {
    #usage> soe-vm-control "operation" --vms "${vm_names}"
    local operation=$1 ; shift ;
    #echo "${operation}:   $@"
    ${soe_vm_control_script} --domain "${domain}" "${operation}" "$@" 
}
function soe-vm-control-vms () {
    #usage> soe-vm-control-vms "operation"
    local operation=$1 ; shift ;
    #echo "VMs: ${vm_fq_names}"
    #echo "${operation}:   $@"

    #iterate over our group of vms:
    for i in ${vm_names} ; do 
	${soe_vm_control_script} --domain "${domain}" "${operation}" --vm "${i}" "$@" 
    done
}
function docker-containers-ls () {
    echo ; echo "Docker containers:" ; docker ps --all
    local status="created restarting running paused exited dead"
    for i in ${status} ; do
	echo ; echo "Docker containers: ${i}" ; docker ps -aq -f status="${i}"
    done
}
function docker-containers-stop () {
    echo ; echo "Stopping docker containers: ${vm_names}" 
    for i in ${vm_names} ; do
	docker stop "${i}"
    done
}
function docker-containers-rm () {
    echo ; echo "Removing docker containers: ${vm_names}" 
    for i in ${vm_names} ; do
	docker rm "${i}"
    done
}

#########################################################################
#That's all we really need. Now we can define some sequences of commands:

function sequence-build-01 () {
    echo "Running sequence to build base image :01."
    soe-vm-control-vms "build"           #build and tag with "01"
    #soe-vm-control-vms "rebuild"        #full rebuild (with --no-cache) and tag with "01"
    soe-vm-control-vms "reimage"         #set "working" image to "01" base os image
    soe-vm-control-vms "run"             #update "working" image by running initial post-boot preparation script at /soe/scripts/vmname-run.sh
}
function sequence-full () {
    echo "Running full sequence to: build image 01, connect, install soe, commit to image :current:"
    sequence-build-01
    #soe-vm-control-vms "soe"            #run soe installation script at /soe/scripts/vmname-run-soe.sh in image: working, create: current
    soe-vm-control-vms "sshd"            #start container & run sshd in container made from image:working
    vm-ansible-setup                     #setup ssh keys & ansible python2-dnf deps etc.
    vm-ansible-run-soe-docker            #runs the soe playbook but skips tasks tagged with docker-skip
    soe-vm-control-vms "commit"          #stops running container, and commits to :current
}
function sequence-ad-hoc () {
    #comment or uncomment as desired:
    echo "Running ad-hoc sequence of commands:"
    #soe-vm-control-vms "build"          #build and tag with "01"
    #soe-vm-control-vms "rebuild"        #rebuild (with --no-cache) and tag with "01"

    #Setup :working image:
    soe-vm-control-vms "reimage"         #set "working" image to "01" base os image
    ###soe-vm-control-vms "refresh"      #set "working" image to "current" soe'd image.
    soe-vm-control-vms "run"             #update "working" image by running initial post-boot preparation script at /soe/scripts/vmname-run.sh

    #Test updates to run-soe script:
    #soe-vm-control-vms "soe-update"     #update run-soe script in image: working"
    #soe-vm-control-vms "soe"            #invoke run-soe script at /soe/scripts/vmname-run-soe.sh in image: working, create: current

    #soe-vm-control-vms "current"        #set :current = :working image.

    #soe-vm-control-vms "create"         #create container from image: working."
    soe-vm-control-vms "sshd"            #create & run sshd in container made from image:working

    #vm-ansible-setup                     #setup ssh keys & ansible python2-dnf deps etc.
    #vm-ansible-run-soe-docker            #runs the soe playbook but skips tasks tagged with docker-skip

    #soe-vm-control-vms "commit"          #stops running container, and commits to :current

    #soe-vm-control-vms "status"          #status of current vm's container
    #soe-vm-control-vms "status_all"      #status of all containers
}

######################################## #Start invoking commands here:
#set-x-on                                #debugging
soe-set-vm_names                         #set default vm_names/vm_fq_names. Comment out to take from environment.
process_args $@                          #do not quote the $@. Mainly just process --vms "foo bar"
msg_start

#soe-vm-control-vms "undefine"           #Wipe working and current images.
docker-containers-stop                   #stop
docker-containers-rm                     #and remove running containers

#sequence-build-01                       #Build base image :01. Past ops are cached so should be fast.
#sequence-full                           #Build base image :01 and run ansible soe scripts, producing image :current.
sequence-ad-hoc                          #Run ad-hoc sequence, tweak as desired.

soe-vm-control-vms "status"              #runtime stats of current vm's container
#soe-vm-control-vms "status_all"         #runtime stats of all containers

echo "Docker images:"; docker images     #Status: images
docker-containers-ls                     #Status: containers

msg_finished
######################################## #Finish here.

#Notes:
#  docker commit --change "ENV DEBUG true"" $CID soe.vorpal_fedora:current
#
#The --change option will apply Dockerfile instructions to the image that is created, eg to change CMD or ENTRYPOINT:
#  Supported Dockerfile instructions: CMD|ENTRYPOINT|ENV|EXPOSE|LABEL|ONBUILD|USER|VOLUME|WORKDIR
#eg:
#  docker commit --change "ENV DEBUG true" c3f279d17e0a  svendowideit/testimage:version3
#  f5283438590d
#  docker inspect -f "{{ .Config.Env }}" f5283438590d
#  [HOME=/ PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin DEBUG=true]

