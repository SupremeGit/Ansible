#!/bin/bash
scriptname="soe-docker-vm-control.sh"
# Script to control our docker vms
#
#By default,on launch, containers run the script specified in Dockerfile "/soe/scripts/fedora-run.sh"

#DEBUG=echo 

vmnames="fedora"
#vmnames="foo bar"
domain="docker.vorpal"

TOOL_DIR="/data-ssd/data/development/src/github/ansible-soe/virt"
#Template dir holds subdirectory: "vm-${domain}" containing Dockerfiles etc:
TEMPLATE_DIR="${TOOL_DIR}/soe-docker/vm-${domain}"
KVM_DIR="/data-ssd/data/kvm"                       #main KVM dir (to copy images into)

BALLS=Salty ; 
debug=0 ;  help=0 ; ok=1
usage () {
    echo
    echo "${scriptname}"
    echo 
    echo "Usage > ${scriptname} --vms \"vm1 vm2 ...\" [operation]"
    echo
    echo "      -h | --help                     Lists this usage information."
    echo "      -d | --debug                    Echo the commands that will be executed."
    echo "      --vms  \"vm1 vm2\"                Space separated quoted list of vm names"
    echo "      --domain  \"soe.vorpal\"          Domain name."
    echo
    echo "Available VMs:"
    echo "               centos7          7.4"
    echo "               fedora26"
    echo "               fedora           27"
    echo "               rawhide"
    echo "               ubuntu           17.04 Desktop"
    echo "               ubuntu_server    17.04 Server"
    echo "               temp"
    echo "               foo"
    echo "               bar"
    echo
    echo "Operations:"
    #echo "      status"
    echo
    echo "      build              Build base image: 01."
    echo "      rebuild            Build fresh base image: 01 with --no-cache."
    echo "      create             Create container from image: working."
    echo "      run                Run image: working. Container removed on exit."
    echo "      soe                Run soe build script in image: working, creating image: current."
    echo "      soe-update         Update the soe build script in image: working."
    echo "      reimage            Set working image to base os image: 01"
    echo "      refresh            Set working image to image: current (soe'd image)."
    echo "      current            Update image: current (soe'd image) from image: working."
    echo "      loop               Run image: working. WIth active command under process monitor, eg: sshd"
    #echo "      commit        Commit changes made to a new image."
    #echo "      update        Update container's post-boot setup script /soe/scripts/vmname-run-soe.sh"
    echo "      "
    echo "Todo:"
    echo
    exit
}
function process_args () {
    #call like: process_args "$@"
    if [[ "$#" == "0" ]]; then
	echo "No arguments. Halp!"
	usage
    fi

    while (( "$#" )); do
	case ${1} in          #switches for this shell script begin with '--'
            -h | help)        usage;;
            -d | --debug)     export debug=1; export DEBUG=echo ; echo -e "\nDebug mode on.";;
            #status | create | define | undefine | reimage | refresh | start | destroy | save | restore | shutdown | reboot | reset )
            build | rebuild | create | run | soe | soe-update | reimage | refresh | current)      
		              operation="${1}" ; echo -e "Executing operation: $1.";;
	    --vms)            ok=1 ; vmnames="$2"  ; echo "Operating on vms: ${vmnames}" ; shift ;;
	    --domain)         domain="$2"  ; echo "Operating on domain: ${domain}" ; shift ;;
            *)                ok=0 ; echo "Unrecognised option." ;  usage ;;
	esac;
	shift
    done
    
    if [ $ok -eq 0 ] ; then echo "Halp. Something isn't right with the command arguments. Exiting." ; usage ; fi
    echo
}
#################

function vm_op_all () {
    operation="$1"
    for i in ${vmnames} ; do 
	echo "${i}:"
	$DEBUG docker ${operation} "${domain}_${i}"
    done
}
function vm_reimage () {
    #create working image from original base image:
    myvmname="$1"
    docker rmi "${domain}_${myvmname}:working" 2>&1 > /dev/null
    docker tag "${domain}_${myvmname}:01"  "${domain}_${myvmname}:working"
}
function vm_reimage_all () {
    for i in ${vmnames} ; do 
	vm_reimage "${i}"
    done
}
function vm_refresh () {
    #create our working image from "current" image with basic build and extra steps applied 
    myvmname="$1"
    docker rmi "${domain}_${myvmname}:working" 2>&1 > /dev/null
    docker tag "${domain}_${myvmname}:current"  "${domain}_${myvmname}:working"
}
function vm_refresh_all () {
    for i in ${vmnames} ; do 
	vm_refresh "${i}"
    done
}
function vm_build_nocache_all () {
    #build image, view build images with "docker images"
    operation="build"                    #build without tagging 
    operation+=" --no-cache"            #use --no-cache to force fresh build:
    for i in ${vmnames} ; do 
	echo "${i}:"
	tags=" -t ${domain}_${i}:01"       #Tag as our standard base image
	$DEBUG docker ${operation} ${tags} "${TEMPLATE_DIR}/${i}/"
    done
}
function vm_create_all () {
    #Create container from image: working
    operation="create"
    for i in ${vmnames} ; do 
	echo "${i}:"
	$DEBUG docker ${operation} "${domain}_${i}:working"
    done
}
function vm_build_all () {
    #build image, view build images with "docker images"
    #REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
    #soe.vorpal_fedora                latest              4c22b1cddd1b        17 seconds ago      3.71 kB

    operation="build"                    #build without tagging 
    for i in ${vmnames} ; do 
	echo "${i}:"
	#tags=" -t ${domain}_${i}"          #build and save image with tag (-t "01" or --tags="01") default tag=latest
	#tags=" --tags ${domain}_${i}:01"  #hmm, "-t" works but "--tags" gives unknown flag: --tags

	tags=" -t ${domain}_${i}:01"       #Tag as our standard base image
	#tags=" -t ${domain}_${i}:current"  #Tag as our current, fully tweaked image
	$DEBUG docker ${operation} ${tags} "${TEMPLATE_DIR}/${i}/"
    done
}
function vm_run_all () {
    #run default bootup cmd specified in Dockerfile "/soe/scripts/fedora-run.sh"
    operation="run"                       #leave old ocntainers around so we can examine fs etc.
    operation+=" --rm"                    #--rm removes old containers after they exit
    #operation+=" --detach"               #don't see output if we detach, but get container ID.
    for i in ${vmnames} ; do 
	echo "Run ${i}:"
	operation+=" --hostname ${i}"      #setting hostname here does not persist in container, only has effect in this run: 
	#$DEBUG docker ${operation} -i -t "${domain}_${i}:02"  "bash" #run interactively with tty
	#$DEBUG docker ${operation}       "${domain}_${i}:latest"     #don't use latest tag

	#run default cmd script:
	#$DEBUG docker ${operation}       "${domain}_${i}" 

	#run specific images:
	#$DEBUG docker ${operation}       "${domain}_${i}:current"    
	$DEBUG docker ${operation}       "${domain}_${i}:working"     #build to work on
	#$DEBUG docker ${operation}        "${domain}_${i}:01"        #01 is the image with base install/prep done.
    done
}
function vm_run_soe_all () {
    #run ${vmname}-run-soe.sh
    operation="run"                       #leave old ocntainers around so we can examine fs etc.
    #operation+=" --rm"                   #--rm removes old containers after they exit
    #operation+=" --detach"                #don't see output if we detach, but get container ID.
    for i in ${vmnames} ; do 
	echo "Run ${i}:"
	operation+=" --hostname ${i}"     #setting hostname here does not persist in container, only has effect in this run: 
	docker ${operation} "${domain}_${i}:working" "/soe/scripts/${i}-run-soe.sh"

	if [[ $? -eq 0 ]] ; then
	    #CID=$( docker ${operation} "${domain}_${i}:working" "/soe/scripts/${i}-run-soe.sh" )
	    #Capturing CID as above only works when using --detach. Without detach, it captures output. 
	    #
	    #Get last created container ID:
	    CID=$(docker ps --latest --quiet)
	    echo "New container ID=${CID}"
	    
	    docker rmi "${domain}_${i}:current"
	    docker commit "${CID}" soe.vorpal_fedora:current
	    
	    #remove container
	    echo "Removing container: ${CID}"
	    docker rm "${CID}"
	else
	    echo "Error running soe."
	fi
    done
}
function vm_soe_update_all () {
    for i in ${vmnames} ; do 
	echo "Soe update: ${i}:"
	operation+=" --hostname ${i}"      #setting hostname here does not persist in container, only has effect in this run: 
	$DEBUG docker create "${domain}_${i}:working"

	#Get last created container ID:
	CID=$(docker ps --latest --quiet)
	echo "New container ID=${CID}"
	
	#Copy files in/out of container
	docker cp "${TOOL_DIR}/soe-docker/vm-docker.vorpal/fedora/scripts/${i}-run-soe.sh" ${CID}:/soe/scripts/${i}-run-soe.sh
	#docker cp ${CID}:/root/fedora-run-soe.log.txt ./

	#clean up:
	docker rmi ${domain}_${i}:working
	docker commit "${CID}" ${domain}_${i}:working

	#remove container
	echo "Removing container: ${CID}"
	docker rm "${CID}"
    done
}
function vm_loop_all () {
    #run some kind of process manager and stay active, eg runnning sshd:
    operation="run --rm"
    for i in ${vmnames} ; do 
	echo "Run ${i}:"
	operation+=" --hostname ${i}"
	$DEBUG docker ${operation} "${domain}_${i}:loop"    "/soe/scripts/${i}-run-sshd.sh"  #run sshd under process manager: monit or supervisord
    done
}
function vm_set_current_all () {
    #tag our working image as our "current" soe'd image:
    for i in ${vmnames} ; do 
	docker rmi ${domain}_${i}:current
	docker tag "${domain}_${i}:working"  "${domain}_${i}:current"
    done
}

function set-x-on () {
    set -x
}
#set-x-on
###########################################################
#start here:

echo
process_args "$@"

#vm_all
if [[ "${operation}" == "create" ]] ; then      #create container from image "current"
    vm_create_all
elif [[ "${operation}" == "build" ]] ; then     #build & tag with "01"
    vm_build_all
elif [[ "${operation}" == "rebuild" ]] ; then   #build & tag with "01", with --no-cache
    vm_build_nocache_all
elif [[ "${operation}" == "run" ]] ; then       #run "working" image         #removes resulting container
    vm_run_all
elif [[ "${operation}" == "reimage" ]] ; then   #set working to 01
    vm_reimage_all
elif [[ "${operation}" == "refresh" ]] ; then   #set working from current
    vm_refresh_all
elif [[ "${operation}" == "current" ]] ; then   #update current from working
    vm_set_current_all
elif [[ "${operation}" == "soe" ]] ; then       #run ${vmname}-run-soe.sh
    vm_run_soe_all
elif [[ "${operation}" == "soe-update" ]] ; then #update ${vmname}-run-soe.sh in image: working
    vm_soe_update_all
elif [[ "${operation}" == "loop" ]] ; then 
    vm_loop_all
else 
    vm_op_all "${operation}"
    #echo "Hmm. Unknown operation: ${operation}"
fi

echo
