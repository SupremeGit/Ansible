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

#BALLS=Salty ; 
debug=0 ;  help=0 ; ok=1
usage () {
    echo
    echo "${scriptname}"
    echo 
    echo "Usage > ${scriptname} --vm \"vmname\" [operation]"
    echo
    echo "      -h | --help                     Lists this usage information."
    echo "      -d | --debug                    Echo the commands that will be executed."
    echo "      --vm  \"vmname\"                  VM to operate on."
    echo "      --domain  \"soe.vorpal\"          Domain name."
    echo
    echo "Available VMs:"
#    echo "               centos7          7.4"
#    echo "               fedora26"
    echo "               fedora           27"
#    echo "               rawhide"
#    echo "               ubuntu           17.04 Desktop"
#    echo "               ubuntu_server    17.04 Server"
#    echo "               temp"
#    echo "               foo"
#    echo "               bar"
    echo
    echo "Operations:"
    echo "      status             Status of container, including runtime stats."
    echo "      status_all         Status of all containers, including runtime stats."
    echo
    echo "      build              Build base image: 01."
    echo "      rebuild            Build fresh base image: 01 with --no-cache."
    echo "      create             Create container from image: working."
    echo "      run                Run post-build script in image: working. Produces updated image: working."
    echo
    echo "      soe                Run soe build script in image: working, creating image: current."
    echo "      soe-update         Update the soe build script in image: working."
    echo
    echo "      sshd               Run sshd in container created from image: working."
    echo "      commit             Commit changes in a container to a new image."
    echo
    echo "      reimage            Set working image to base os image: 01"
    echo "      refresh            Set working image to image: current (soe'd image)."
    echo "      current            Update image: current (soe'd image) from image: working."
    echo "      undefine           Blat the working & current images. Keep the base 01 image."
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
            status | status_all | build | rebuild | create | run | soe | soe-update | \
	    sshd | commit | reimage | refresh | current | undefine)      
		              operation="${1}" ; echo -e "Executing operation: $1.";;
	    --vm)             ok=1 ; vmname="$2"  ; echo "Operating on vm: ${vmname}" ; shift ;;
	    --domain)         domain="$2"  ; echo "Operating on domain: ${domain}" ; shift ;;
            *)                ok=0 ; echo "Unrecognised option." ;  usage ;;
	esac;
	shift
    done
    
    if [ $ok -eq 0 ] ; then echo "Halp. Something isn't right with the command arguments. Exiting." ; usage ; fi
    echo
}
function set-x-on () {
    set -x
}

#################

function vm_op () {
    local operation="$1"
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
    local operation="build"             #build without tagging 
    operation+=" --no-cache"            #use --no-cache to force fresh build:
    echo "${vmname}:"
    local tags=" -t ${domain}_${vmname}:01"       #Tag as our standard base image
    $DEBUG docker ${operation} ${tags} "${TEMPLATE_DIR}/${vmname}/"
}
function vm_create () {
    #Create container from image: working
    local operation="create"
    echo "${vmname}:"
    $DEBUG docker ${operation} "${domain}_${vmname}:working"
}
function vm_build () {
    #build image, view build images with "docker images"
    #REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
    #soe.vorpal_fedora                latest              4c22b1cddd1b        17 seconds ago      3.71 kB
    local operation="build"                  #build without tagging 
    echo "Build ${vmname}:"
    #tags=" -t ${domain}_${vmname}"          #build and save image with tag (-t "01" or --tags="01") default tag=latest
    #tags=" --tags ${domain}_${vmname}:01"   #hmm, "-t" works but "--tags" gives unknown flag: --tags
    local tags=" -t ${domain}_${vmname}:01"       #Tag as our standard base image
    #tags=" -t ${domain}_${vmname}:current"  #Tag as our current, fully tweaked image
    $DEBUG docker ${operation} ${tags} "${TEMPLATE_DIR}/${vmname}/"
}
function vm_run () {
    #run default bootup cmd specified in Dockerfile "/soe/scripts/${vmname}-run.sh"
    echo "Run ${vmname}:"
    local operation="run"                 #leave old ocntainers around so we can examine fs etc.
    #operation+=" --rm"                   #--rm removes old containers after they exit
    #operation+=" --detach"               #don't see output if we detach, but get container ID.
    operation+=" --hostname ${vmname} --net docker-net --ip 192.168.130.100"    #setting hostname here does not persist in container, only has effect in this run: 

    #operation+=" -i -t "${domain}_${vmname}:02"  "bash"    #run interactively with tty
    #operation+=" ${domain}_${vmname}:latest"               #don't use latest tag

    #run specific images:
    #operation+=" ${domain}_${vmname}:current"    
    operation+=" ${domain}_${vmname}:working"
    #operation+="${domain}_${vmname}:01"         #01 is the image with base install/prep done.

    operation+=" /soe/scripts/${vmname}-run.sh"  #comment this out to run default cmd script specified in dockerfile:
    $DEBUG docker ${operation}

    if [[ $? -eq 0 ]] ; then
	#CID=$( docker ${operation} "${domain}_${vmname}:working" "/soe/scripts/${vmname}-run-soe.sh" )
	#Capturing CID as above only works when using --detach. Without detach, it captures output. 
	#
	#Get last created container ID:
	CID=$(docker ps --latest --quiet)
	echo "New container ID=${CID}"

	echo "Committing to ${domain}_${vmname}:temp"
	docker commit "${CID}" ${domain}_${vmname}:temp
	#remove container
	echo "Removing container: ${CID}"
	docker rm "${CID}"
	docker rmi "${domain}_${vmname}:working"
	echo "Tagging ${domain}_${vmname}:working= :temp"
	docker tag "${domain}_${vmname}:temp" "${domain}_${vmname}:working"
	docker rmi "${domain}_${vmname}:temp"
    else
	echo "Error running soe."
    fi
}
function vm_run_soe () {
    #run ${vmname}-run-soe.sh
    echo "Run soe build script on: working, produces: current."
    local operation="run"                  #leave old ocntainers around so we can examine fs etc.
    operation+=" --hostname ${vmname} --net docker-net --ip 192.168.130.100 " #setting hostname here does not persist in container, only has effect in this run: 
    docker ${operation} "${domain}_${vmname}:working" "/soe/scripts/${vmname}-run-soe.sh"
    if [[ $? -eq 0 ]] ; then
	#CID=$( docker ${operation} "${domain}_${vmname}:working" "/soe/scripts/${vmname}-run-soe.sh" )
	#Capturing CID as above only works when using --detach. Without detach, it captures output. 
	#
	#Get last created container ID:
	CID=$(docker ps --latest --quiet)
	echo "New container ID=${CID}"
	
	docker rmi "${domain}_${vmname}:current"
	echo "Committing to ${domain}_${vmname}:current"
	docker commit "${CID}" ${domain}_${vmname}:current
	
	#remove container
	echo "Removing container: ${CID}"
	docker rm "${CID}"
    else
	echo "Error running soe."
    fi
}
function vm_sshd () {
    #run sshd
    echo "Run sshd in container launched from: working."
    local operation="run "
    operation+=" --detach=true"
    operation+=" --name ${vmname} --hostname ${vmname}"
    operation+=" --net docker-net --ip 192.168.130.100"
    operation+=" --add-host il-duce:192.168.1.100"
    #operation+=" --cpus=4"
    #operation+=" --memory=1g"
    operation+=" ${domain}_${vmname}:working"
    operation+=" /usr/sbin/sshd -D"  #-D does not daemonise
    echo docker ${operation} $@
    docker ${operation} $@
}
function vm_commit () {
    #commit container into image: current
    echo "Commit container, produces: current."
    docker stop "${vmname}"
    docker rmi  "${domain}_${vmname}:current"
    echo "Commiting to ${domain}_${vmname}:current"
    docker commit "${vmname}" "${domain}_${vmname}:current"
    docker rm "${vmname}"
}

function vm_soe_update () {
    echo "Update soe build script in image: working: ${vmname}:"
    local operation="run"                   #leave old ocntainers around so we can examine fs etc.
    operation+=" --hostname ${vmname}"      #setting hostname here does not persist in container, only has effect in this run: 
    $DEBUG docker ${operation} "${domain}_${vmname}:working"
    
    #Get last created container ID:
    CID=$(docker ps --latest --quiet)
    echo "New container ID=${CID}"
    
    #Copy files in/out of container:
    #docker cp "${TOOL_DIR}/soe-docker/vm-docker.vorpal/${vmname}/scripts/${vmname}-run-soe.sh" ${CID}:/soe/scripts/${vmname}-run-soe.sh
    #docker cp "${TOOL_DIR}/soe-docker/vm-docker.vorpal/${vmname}/scripts/*" ${CID}:/soe/scripts/
    docker cp "${TOOL_DIR}/soe-docker/vm-docker.vorpal/${vmname}/scripts" ${CID}:/soe/
    #docker cp ${CID}:/root/${vmname}-run-soe.log.txt ./
    
    #clean up:
    docker rmi ${domain}_${vmname}:working
    echo "Committing to ${domain}_${vmname}:working"
    docker commit "${CID}" ${domain}_${vmname}:working
    
    #remove container
    echo "Removing container: ${CID}"
    docker rm "${CID}"
}
function vm_set_current () {
    #tag our working image as our "current" soe'd image:
    docker rmi ${domain}_${vmname}:current
    echo "Tagging: ${domain}_${vmname}:current = :working"
    docker tag "${domain}_${vmname}:working"  "${domain}_${vmname}:current"
}
function vm_undefine () {
    docker rmi --force ${domain}_${vmname}:current
    docker rmi --force ${domain}_${vmname}:working
    #docker rmi --force ${domain}_${vmname}:01       Always keep the base image.
}
function vm_status () {
    #get stats on a container (ie if we've launched one running sshd).
    myvmname="$1"
    #args=(combined.pdf "my file.pdf");
    local operation=("stats")
    operation+=("--no-stream=true")
    operation+=("--all=true")                  #show non-running containers
    #operation+=("--format='table {{.ID}}'")   #ID is the long-format container ID. Too long.

    #Bah. No way to stop docker mangling this! When passed to docker cmdline as part of a var, docker always splits after table, even through quotes!
    #operation+=("--format")
    #operation+=('"table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.MemPerc}}\t{{.PIDs}}"')

    #dqt='"'  #doublequote.
    #operation+=("--format=${dqt}table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.MemPerc}}\t{{.PIDs}}${dqt}")

    #operation+=('--format="table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.MemPerc}}\t{{.PIDs}}"')
    #operation+=("--format="'"'"table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.MemPerc}}\t{{.PIDs}}"'"')

    ##echo "${operation[@]}"
    ##echo ${operation[@]}
    #printf '%s\n' "${operation[@]}"  #nice, one line per array element

    #But it works when you pass directly on docker commandline. So stupid:
    #docker ${operation} --format="table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.MemPerc}}\t{{.PIDs}}" ${myvmname}

    #Even this fails, and even when -x shows it is passed to docker as a single-quoted unit with double-quotes intact:
    #fmt='--format="table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.MemPerc}}\t{{.PIDs}}"'
    #I swear docker must not be parsing this commandline correctly

    #Unbelievable. This gets it:
    operation+=("--format")
    fmt="table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.MemPerc}}\t{{.PIDs}}"
    docker "${operation[@]}" "${fmt}" ${myvmname}
}
function vm_status_all () {
    #get stats on all containers, even those that are not running
    vm_status ""                       #omitting container name will give stats on all.
}

########################################################### #start here:
#set-x-on #debugging
echo
process_args "$@"

case ${operation} in #switches for this shell script begin with '--'
    -h | --help)        usage;;

    status)           vm_status ${vmname}   ;; #status & stats of container
    status_all)       vm_status_all         ;; #status & stats of container

    build)            vm_build              ;; #build & tag with "01"
    rebuild)          vm_build_nocache      ;; #build & tag with "01", with --no-cache
    create)           vm_create             ;; #create container from image "current"

    run)              vm_run                ;; #run image: working, removes resulting container
    soe)              vm_run_soe            ;; #run ${vmname}-run-soe.sh in image: working
    soe-update)       vm_soe_update         ;; #update ${vmname}-run-soe.sh in image: working

    sshd)             vm_sshd               ;; #run sshd in container
    commit)           vm_commit             ;; #commit container to :current

    reimage)          vm_reimage            ;; #set working to 01
    refresh)          vm_refresh            ;; #set working from current
    current)          vm_set_current        ;; #update current from working
    undefine)         vm_undefine           ;; #blat working, current images

    *)                vm_op "${operation}"  ;; 
    #*)               ok=0 ; echo "Unrecognised option." ;  usage ;;
esac;
echo
