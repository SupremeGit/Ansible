#!/bin/bash
scriptname="soe-docker-vm-control.sh"
# Script to control our docker vms
#
#By default,on launch, containers run the script specified in Dockerfile "/soe/scripts/fedora-run.sh"

#DEBUG=echo 

vmnames="fedora"
#vmnames="foo bar"
domain="docker.vorpal"

TOOL_DIR="/data-ssd/data/development/src/github/ansible-soe/virt/soe-docker"
#Template dir holds subdirectory: "vm-${domain}" holding libvirt xml files based off a template file at ${TEMPLATE_DIR}/soe.xml
#TEMPLATE_DIR=/etc/libvirt/z_templates
TEMPLATE_DIR="${TOOL_DIR}/vm-${domain}"
KVM_DIR="/data-ssd/data/kvm"                       #main KVM dir (to copy images into)

#switch to creating new image:
#BLANK_IMAGE="${IMAGE_DIR}/25G.qcow2"               #blank, sparse image, small & quick to copy

BALLS=Salty ; debug=0 ;  help=0 ; ok=1
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
    echo "      build         Build base image."
    echo "      run           Run VM."
    echo "      commit        Commit changes made to a new image."
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
            build | run | update)      operation="${1}" ; echo -e "Executing operation: $1.";;
	    --vms)            ok=1 ; vmnames="$2"  ; echo "Operating on vms: ${vmnames}" ; shift ;;
	    --domain)         domain="$2"  ; echo "Operating on domain: ${domain}" ; shift ;;
            *)                ok=0 ; echo "Unrecognised option." ;  usage ;;
	esac;
	shift
    done
    
    if [ $ok -eq 0 ] ; then echo "Halp. Something isn't right with the command arguments. Exiting." ; usage ; fi
    echo
}

function vm_op_all () {
    operation="$1"
    for i in ${vmnames} ; do 
	echo "${i}:"
	$DEBUG docker "${operation}"
    done
}

function vm_op_build () {
    #build image, view build images with "docker images"
    #REPOSITORY                       TAG                 IMAGE ID            CREATED             SIZE
    #soe.vorpal_fedora                latest              4c22b1cddd1b        17 seconds ago      3.71 kB

    #operation="build --no-cache -t "          #use --no-cache to force fresh build:
    operation="build -t"
    for i in ${vmnames} ; do 
	echo "${i}:"
	$DEBUG docker ${operation} "${domain}_${i}" "${TEMPLATE_DIR}/${i}/"
    done
}

function vm_op_run () {
    #operation="run"                       #leave old ocntainers around so we can examine fs etc.
    operation="run --rm"                   #--rm removes old containers after they exit
    #operation="run --detach"              #don't see output if we detach
    for i in ${vmnames} ; do 
	echo "Run ${i}:"
	#if no command specified, default is to 
	operation+=" --hostname ${i}"
	$DEBUG docker ${operation}  "${domain}_${i}:latest"
	#$DEBUG docker ${operation} "${domain}_${i}:00"    #run image prepared earlier
	#$DEBUG docker ${operation} "${domain}_${i}:01"    #run image prepared earlier
	#$DEBUG docker ${operation} "${domain}_${i}:02"    #run image prepared earlier
	#$DEBUG docker ${operation} "${domain}_${i}"       #run default bootup cmd specified in Dockerfile "/soe/scripts/fedora-run.sh"
	#$DEBUG docker ${operation} "${domain}_${i}"      "/soe/scripts/fedora-run-soe.sh"
    done
}

#################

function check_operation_retry () {
    op="$1"
    if [[ "meh" == *"${op}"* ]] ; then 
	echo "Valid retry operation: ${op}"
	return 1;
    else
	return 0
    fi
}
function check_operation () {
    op="$1"
    if [[ "meh" == *"${op}"* ]] ; then 
	echo "Valid normal operation: ${op}"
	return 1;
    else
	return 0
    fi
}

function check_xml_operation () {
    op="$1"
    if [[ "maybebuild" == *"${op}"* ]] ; then 
	echo "Valid xml_file operation: ${op}"
	return 1;
    else
	return 0
    fi
}
function retry () {
    vmname="$1"
    operation="$2"
    RETRIES=3
    for j in 1 to ${RETRIES} ; do 

	#docker:
	$DEBUG docker ${operation} "${domain}_${vmname}"

	status=$?
	if [[ ${status} -ne 0 ]] ; then 
	    echo "Retrying "
	    sleep ${LIBVIRT_DELAY}
	else
	    break
	fi
    done
}
function vm_op_all () {
    operation="$1"
    for i in ${vmnames} ; do 
	echo "${i}:"
	$DEBUG docker ${operation} "${domain}_${i}"
    done
}
function vm_op_all_retry () {
    operation="$1"
    for i in ${vmnames} ; do 
	echo "${i}:"
	retry "${i}" "${operation}"
    done
}
function vm_xml_op_all () {
    operation="$1"
    for i in ${vmnames} ; do 
	echo "${i}:"
	$DEBUG docker ${operation} "${TEMPLATE_DIR}/${i}-docker-compose.yml"
    done
}
function vm_reimage () {
    echo > /dev/null
    #$DEBUG cp --sparse=always -v "${BLANK_IMAGE}" "${VM_DIR}/${domain}/${1}.qcow2"
}
function vm_reimage_all () {
    for i in ${vmnames} ; do 
	vm_reimage "${i}"
    done
}
function vm_refresh () {
    mydomain="$1"
    myvmname="$2"
    #$DEBUG cp --sparse=always -v "${IMAGE_DIR}/${mydomain}/${myvmname}-vm01.qcow2" "${VM_DIR}/${mydomain}/${myvmname}.qcow2"
}
function vm_refresh_all () {
    for i in ${vmnames} ; do 
	vm_refresh "${domain}" "${i}"
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
if [[ $( check_operation "${operation}" ) ]] ; then 
    vm_op_all "${operation}"
elif [[ $( check_operation_retry "${operation}" ) ]] ; then 
    vm_op_all_retry "${operation}"
elif [[ "${operation}" == "build" ]] ; then 
    vm_op_build
elif [[ "${operation}" == "run" ]] ; then 
    vm_op_run
else 
    echo "Hmm. Unknown operation: ${operation}"
fi

echo
