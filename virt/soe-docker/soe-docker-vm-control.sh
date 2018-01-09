#!/bin/bash
scriptname="soe-docker-vm-control.sh"
# Script to control our docker vms
#
#By default,on launch, containers run the script specified in Dockerfile "/soe/scripts/fedora-run.sh"

#DEBUG=echo 

vmname="fedora"
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
    echo "      --vm  \"vm1\"                     Space separated quoted list of vm names"
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
    echo "      undefine           Blat the working & current images. Keep the base 01 image."
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
            build | rebuild | create | run | soe | soe-update | reimage | refresh | current | undefine)      
		              operation="${1}" ; echo -e "Executing operation: $1.";;
	    --vm)             ok=1 ; vmname="$2"  ; echo "Operating on vms: ${vmnames}" ; shift ;;
	    --domain)         domain="$2"  ; echo "Operating on domain: ${domain}" ; shift ;;
            *)                ok=0 ; echo "Unrecognised option." ;  usage ;;
	esac;
	shift
    done
    
    if [ $ok -eq 0 ] ; then echo "Halp. Something isn't right with the command arguments. Exiting." ; usage ; fi
    echo
}
#################

function vm_op () {
    operation="$1"
    echo "${i}:"
    $DEBUG docker ${operation} "${domain}_${i}"
}
function vm_reimage () {
    #create working image from original base image:
    docker rmi "${domain}_${vmname}:working" > /dev/null 2>&1
    docker tag "${domain}_${vmname}:01"  "${domain}_${vmname}:working"
}
function vm_refresh () {
    #create our working image from "current" image with basic build and extra steps applied 
    docker rmi "${domain}_${vmname}:working" > /dev/null 2>&1
    docker tag "${domain}_${vmname}:current"  "${domain}_${vmname}:working"
}
function vm_build_nocache () {
    #build image, view build images with "docker images"
    operation="build"                    #build without tagging 
    operation+=" --no-cache"            #use --no-cache to force fresh build:
    echo "${vmname}:"
    tags=" -t ${domain}_${vmname}:01"       #Tag as our standard base image
    $DEBUG docker ${operation} ${tags} "${TEMPLATE_DIR}/${vmname}/"
}
function vm_create () {
    #Create container from image: working
    operation="create"
    echo "${vmname}:"
    $DEBUG docker ${operation} "${domain}_${vmname}:working"
}
function vm_build () {
    #build image, view build images with "docker images"
    #REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
    #soe.vorpal_fedora                latest              4c22b1cddd1b        17 seconds ago      3.71 kB
    operation="build"                    #build without tagging 
    echo "Build ${vmname}:"
    #tags=" -t ${domain}_${vmname}"          #build and save image with tag (-t "01" or --tags="01") default tag=latest
    #tags=" --tags ${domain}_${vmname}:01"  #hmm, "-t" works but "--tags" gives unknown flag: --tags
    tags=" -t ${domain}_${vmname}:01"       #Tag as our standard base image
    #tags=" -t ${domain}_${vmname}:current"  #Tag as our current, fully tweaked image
    $DEBUG docker ${operation} ${tags} "${TEMPLATE_DIR}/${vmname}/"
}
function vm_run () {
    #run default bootup cmd specified in Dockerfile "/soe/scripts/fedora-run.sh"
    operation="run"                       #leave old ocntainers around so we can examine fs etc.
    operation+=" --rm"                    #--rm removes old containers after they exit
    #operation+=" --detach"               #don't see output if we detach, but get container ID.
    echo "Run ${vmname}:"
    operation+=" --hostname ${vmname}"      #setting hostname here does not persist in container, only has effect in this run: 
    #$DEBUG docker ${operation} -i -t "${domain}_${vmname}:02"  "bash" #run interactively with tty
    #$DEBUG docker ${operation}       "${domain}_${vmname}:latest"     #don't use latest tag
    #run default cmd script:
    #$DEBUG docker ${operation}       "${domain}_${vmname}" 
    #run specific images:
    #$DEBUG docker ${operation}       "${domain}_${vmname}:current"    
    $DEBUG docker ${operation}       "${domain}_${vmname}:working"     #build to work on
    #$DEBUG docker ${operation}        "${domain}_${vmname}:01"        #01 is the image with base install/prep done.
}
function vm_run_soe () {
    #run ${vmname}-run-soe.sh
    echo "Run soe build script on: working, produces: current: ${i}:"
    operation="run"                   #leave old ocntainers around so we can examine fs etc.
    operation+=" --hostname ${vmname}"     #setting hostname here does not persist in container, only has effect in this run: 
    docker ${operation} "${domain}_${vmname}:working" "/soe/scripts/${vmname}-run-soe.sh"
    if [[ $? -eq 0 ]] ; then
	#CID=$( docker ${operation} "${domain}_${vmname}:working" "/soe/scripts/${vmname}-run-soe.sh" )
	#Capturing CID as above only works when using --detach. Without detach, it captures output. 
	#
	#Get last created container ID:
	CID=$(docker ps --latest --quiet)
	echo "New container ID=${CID}"
	
	docker rmi "${domain}_${vmname}:current"
	docker commit "${CID}" soe.vorpal_fedora:current
	
	#remove container
	echo "Removing container: ${CID}"
	docker rm "${CID}"
    else
	echo "Error running soe."
    fi
}
function vm_soe_update () {
    echo "Update soe build script in image: working: ${vmname}:"
    operation="run"                    #leave old ocntainers around so we can examine fs etc.
    operation+=" --hostname ${vmname}"      #setting hostname here does not persist in container, only has effect in this run: 
    $DEBUG docker ${operation} "${domain}_${vmname}:working"
    
    #Get last created container ID:
    CID=$(docker ps --latest --quiet)
    echo "New container ID=${CID}"
    
    #Copy files in/out of container
    docker cp "${TOOL_DIR}/soe-docker/vm-docker.vorpal/fedora/scripts/${vmname}-run-soe.sh" ${CID}:/soe/scripts/${vmname}-run-soe.sh
    #docker cp ${CID}:/root/fedora-run-soe.log.txt ./
    
    #clean up:
    docker rmi ${domain}_${vmname}:working
    docker commit "${CID}" ${domain}_${vmname}:working
    
    #remove container
    echo "Removing container: ${CID}"
    docker rm "${CID}"
}
function vm_loop () {
    #run some kind of process manager and stay active, eg runnning sshd:
    operation="run --rm"
    echo "Loop ${vmname}:"
    operation+=" --hostname ${vmname}"
    $DEBUG docker ${operation} "${domain}_${vmname}:loop"    "/soe/scripts/${vmname}-run-sshd.sh"  #run sshd under process manager: monit or supervisord
}
function vm_set_current () {
    #tag our working image as our "current" soe'd image:
    docker rmi ${domain}_${vmname}:current
    docker tag "${domain}_${vmname}:working"  "${domain}_${vmname}:current"
}
function vm_undefine () {
    docker rmi --force ${domain}_${vmname}:current
    docker rmi --force ${domain}_${vmname}:working
    #docker rmi --force ${domain}_${vmname}:01       Always keep the base image.
}

function set-x-on () {
    set -x
}
#set-x-on
###########################################################
#start here:
echo
process_args "$@"

case ${operation} in          #switches for this shell script begin with '--'
    -h | help)        usage;;
    create)           vm_create             ;; #create container from image "current"
    build)            vm_build              ;; #build & tag with "01"
    rebuild)          vm_build_nocache      ;; #build & tag with "01", with --no-cache
    run)              vm_run                ;; #run image: working, removes resulting container
    soe)              vm_run_soe            ;; #run ${vmname}-run-soe.sh in image: working
    soe-update)       vm_soe_update         ;; #update ${vmname}-run-soe.sh in image: working

    reimage)          vm_reimage            ;; #set working to 01
    refresh)          vm_refresh            ;; #set working from current
    current)          vm_set_current        ;; #update current from working
    undefine)         vm_undefine           ;; #blat working, current images

    loop)             vm_loop               ;;
    *)                vm_op "${operation}"  ;; 
    #*)                ok=0 ; echo "Unrecognised option." ;  usage ;;
esac;

echo
