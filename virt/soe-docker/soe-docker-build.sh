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
#      function docker-run-interactive () { snapshot="${1}" ; shift ; docker run --tty --interactive --name "fedora" --hostname "fedora" "${snapshot}" /bin/bash $@ ; }
#      alias docker-container-restart="docker start -ai"
#    Then you can:
#    docker-run-interactive soe.vorpal_fedora:current
#    docker-container-restart fedora

#Docker system config is at:
#  config file: ~/.docker/config.json
#  images stored in: /var/lib/docker
#  cd /data-ssd/data/development/os/docker/

#soe-vm-control.sh operates on a group of vms defined from a libvirt template:
#  available operations: create, define, undefine, define, reimage, refresh, start, destroy, save. restore, shutdown, reboot, reset
TOOL_DIR="/data-ssd/data/development/src/github/ansible-soe/virt"
soe_vm_control_script="${TOOL_DIR}/soe-docker/soe-docker-vm-control.sh"
domain="soe.vorpal"       #vm "domain" to use when creating vms
source "${TOOL_DIR}/soe-ansible/soe-ansible.sh"     #source functions to run our ansible soe playbooks
SSHD_DELAY=15             #extra delay to wait for ssh.

#vms to operate on:
#def_vm_names="centos7 fedora ubuntu ubuntu_server temp foo bar"
#def_vm_names="fedora ubuntu_server temp"
#def_vm_names="fedora temp"
def_vm_names="fedora"
vm_names=""

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
function usage () {
    echo "Usage:"
    exit
}

function process_args () {
    #call like: process_args "$@"
    #if [[ "$#" == "0" ]]; then
	#echo "No arguments. Halp!"
	#usage
    #fi
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

#docker commands:
function docker-container-ls () {
    echo ; echo "Docker containers:" ; docker ps --all
    local status="created restarting running paused exited dead"
    for i in ${status} ; do
	echo ; echo "Docker containers: ${i}" ; docker ps -aq -f status="${i}"
    done
}

################################################
#Adapt these from libvirt to docker as required:

#misc:
function msg_start () {
    echo
    echo "Started"
    date +%H-%M-%S
    echo
}
function msg_finished () {
    echo
    echo "Finished:"
    date +%H-%M-%S
    echo
}

#testing:
function set-x-on () {
    set -x
}
function set-x-off () {
    set +x
}
function test-vm-control () {
    soe-vm-control "status" --vms "${vm_names}"
}

#That's all we really need. Now we can define some groups of commands and then some sequences which use these groups:

#sequences:
function sequence-full () {
    echo "Running full sequence to: define, start, connect, install soe, shutdown, undefine:"

    #build image: 01:
    soe-vm-control-vms "build"         #build and tag with "01"
    #soe-vm-control-vms "rebuild"       #rebuild (with --no-cache) and tag with "01"

    soe-vm-control-vms "reimage"       #Set "working" image to "01" base os image
    #soe-vm-control-vms "refresh"       #Set "working" image to "current" soe'd image.
    soe-vm-control-vms "current"       #Update "current" soe'd image from "working" image.
    
    #soe-vm-control-vms "run"           #Use "working" image to run initial post-boot preparation script at /soe/scripts/vmname-run.sh
    soe-vm-control-vms "soe"            #Run soe installation script at /soe/scripts/vmname-run-soe.sh in image: working, create: current
}
function sequence-partial () {
    echo "Running ad-hoc sequence of commands:"   #comment or uncomment as desired:
    #soe-vm-control-vms "status"

    #soe-vm-control-vms "undefine"      #Wipes 01, working and current images.

    #build image: 01:
    #soe-vm-control-vms "build"         #build and tag with "01"
    #soe-vm-control-vms "rebuild"       #rebuild (with --no-cache) and tag with "01"

    #Setup working image:
    soe-vm-control-vms "reimage"        #Set "working" image to "01" base os image
    ###soe-vm-control-vms "refresh"       #Set "working" image to "current" soe'd image.
    soe-vm-control-vms "current"        #Update "current" soe'd image from "working" image.

    #Test updates to run-soe script:
    soe-vm-control-vms "soe-update"     #Update run-soe script in image: working"
    soe-vm-control-vms "soe"            #Run soe installation script at /soe/scripts/vmname-run-soe.sh in image: working, create: current
}
function sequence-test () {
    echo "Running test sequence of commands:"   #comment or uncomment as desired:
    #soe-vm-control-vms "status"
}
#set-x-on
########################################Start invoking commands here:
#when not set here, vm_names and vm_fq_names are taken from environment, or from $@:
soe-set-vm_names   #set default vm_names
process_args $@    #Do not quote the $@. Mainly just process --vms "foo bar"
msg_start

#soe-vm-control-vms "undefine"      #Wipes working and current images.

sequence-full                       #Put as much soe config as possible in Dockerfile, and build here. Past ops are cached so should be fast.
#sequence-partial                   #Update & run soe script & other ad-hoc commands
#sequence-test 

#soe-vm-control-vms "create"         #Create container from image: working."

#status:
echo "Docker images:"; docker images
docker-container-ls

msg_finished
########################################Finish here.

#  docker commit --change "ENV DEBUG true"" $CID soe.vorpal_fedora:current
#
#The --change option will apply Dockerfile instructions to the image that is created, eg to change CMD or ENTRYPOINT:
#  Supported Dockerfile instructions: CMD|ENTRYPOINT|ENV|EXPOSE|LABEL|ONBUILD|USER|VOLUME|WORKDIR
#eg:
#  docker commit --change "ENV DEBUG true" c3f279d17e0a  svendowideit/testimage:version3
#  f5283438590d
#  docker inspect -f "{{ .Config.Env }}" f5283438590d
#  [HOME=/ PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin DEBUG=true]

