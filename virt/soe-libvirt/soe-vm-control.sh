#!/bin/bash
scriptname="soe-vm-control.sh"
# Script to control our vms
#
# Works on libvirt template files which specify a bunch of vms in a group (domain)
# The image files, running vm, and templates must be set below.
#
# Also, the vm template files must have:
#  - name set to match: ${domain}_${vmname} eg:  <name>soe.vorpal_new</name>
#  - disk image set to match: ${VM_DIR}/${domain}/${vmname}.qcow2 eg: <source file='/data-ssd/data/kvm/vm/soe.vorpal/new.qcow2'/>

#DEBUG=echo 
vmnames="foo bar"
domain="soe.vorpal"

TOOL_DIR="/data-ssd/data/development/src/github/ansible-soe/virt/soe-libvirt"
#Template dir holds subdirectory: "domain-soe" holding libvirt xml files based off a templat file at ${TEMPLATE_DIR}/soe.xml
#TEMPLATE_DIR=/etc/libvirt/z_templates
TEMPLATE_DIR="${TOOL_DIR}/vm-${domain}"
KVM_DIR="/data-ssd/data/kvm"                       #main KVM dir (to copy images into)

#Shouldn't have to change anything below here:
LIBVIRT_DELAY=1;                                   #delay to avoid lame libvirt lockups
VM_DIR="${KVM_DIR}/vm"                             #running vms go in ${VM_DIR}/${domain}
IMAGE_DIR="${KVM_DIR}/images"                      #saved vms, refresh copies images freshly installed osfrom here

#switch to creating new image:
BLANK_IMAGE="${IMAGE_DIR}/25G.qcow2"               #blank, sparse image, small & quick to copy

BALLS=Salty ; debug=0 ;  help=0 ; ok=1
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
    echo "      status"
    echo
    echo "      create         Create and start."
    echo "      define         Create VM."
    echo "      undefine       Delete VM from libvirt (keeps disk image)."
    echo "      reimage        Overwrite the disk image with an empty one (default domain=soe)."
    echo "      refresh        Overwrite the disk image with a freshly installed one (default domain=soe)."
    echo
    echo "      start"
    echo "      destroy        Stop"
    echo "      save"
    echo "      restore"
    echo
    echo "      shutdown"
    echo "      reboot"
    echo "      reset"
    echo "      "
    echo "Todo:"
    echo "      suspend resume managedsave autostart-on autostart-off "  #suspend/resume=pause/unpause
    echo "      desc = set description"
    echo "      set-user-password domain user password [--encrypted]"
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
            -d | --debug )    export debug=1; export DEBUG=echo ; echo -e "\nDebug mode on.";;
            status | create | define | undefine | reimage | refresh | start | destroy | save | restore | shutdown | reboot | reset )
                operation="${1}" ; echo -e "Executing operation: $1.";;
	    --vm)            ok=1 ; vmname="$2"  ; echo "Operating on vms: ${vmname}" ; shift ;;
	    --domain)         domain="$2"  ; echo "Operating on domain: ${domain}" ; shift ;;
            *)                ok=0 ; echo "Unrecognised option." ;  usage ;;
	esac;
	shift
    done
    
    if [ $ok -eq 0 ] ; then echo "Halp. Something isn't right with the command arguments. Exiting." ; usage ; fi
    echo
}

###################vm functions
function vm_op () {
    local operation="$1"
    echo "${vmname}:"
    $DEBUG virsh ${operation} "${domain}_${vmname}"
}
function vm_op_retry () {
    local operation="$1"
    echo "retry-${operation} ${vmname}:"
    RETRIES=3
    for j in 1 to ${RETRIES} ; do 
	$DEBUG virsh ${operation} "${domain}_${vmname}"
	status=$?
	if [[ ${status} -ne 0 ]] ; then 
	    echo "Retrying "
	    sleep ${LIBVIRT_DELAY}
	else
	    break
	fi
    done
}
function vm_xml_op () {
    local operation="$1"
    echo "${operation} ${vmname}:"
    $DEBUG virsh ${operation} "${TEMPLATE_DIR}/${domain}_${vmname}.xml"
}
function vm_reimage () {
    $DEBUG cp --sparse=always -v "${BLANK_IMAGE}" "${VM_DIR}/${domain}/${vmname}.qcow2"
}
function vm_refresh () {
    $DEBUG cp --sparse=always -v "${IMAGE_DIR}/${domain}/${vmname}-vm01.qcow2" "${VM_DIR}/${domain}/${vmname}.qcow2"
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
    start)            vm_op_retry "${operation}" ;;
    create | define)  vm_xml_op "${operation}" ;;
    reimage)          vm_reimage ;;
    refresh)          vm_refresh ;;
    status)           vm_op "domstate --reason" ;;
    *)                vm_op "${operation}" ;;
    #*)                ok=0 ; echo "Unrecognised option." ;  usage ;;
esac;

echo
