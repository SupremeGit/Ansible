#!/bin/bash
scriptname="soe-ansible.sh"

#source after domain is set:
hostgroup=${domain%.*}  #use leftmost part of domain for ansible hostgroup

var_playbook_connect="/etc/ansible/playbooks/connect-host.yml"       #${var_playbook_connect}
var_playbook_soe="/etc/ansible/playbooks/soe.yml"    	             #${var_playbook_soe}
vault="--vault-password-file ~/.ansible_vault_password"              #${vault}
hostsfile="-i /etc/ansible/hosts"                                    #${hostsfile} 

#basic command without playbook, facts on/off:
function ansible-play           () { ansible-playbook ${vault} ${hostsfile} --extra-vars "hostgroups=${hostgroup}"             "$@" ; }
function ansible-play-facts-off () { ansible-playbook ${vault} ${hostsfile} --extra-vars "hostgroups=${hostgroup} facts_on=no" "$@" ; }

#main playbook commmands:
function ansible-connect        () { ansible-play-facts-off ${var_playbook_connect} --tags=connect-new-host                "$@" ; }
function ansible-requirements   () { ansible-play           ${var_playbook_connect} --tags=ansible_requirements            "$@" ; }
function ansible-soe            () { ansible-play           ${var_playbook_soe}     --extra-vars "hostgroups=${hostgroup}" "$@" ; }

function vm-ansible-setup () {
    echo "Connecting vis ssh key: ${vm_fq_names}"             ; ansible-connect      --limit "${vm_fq_names}"
    echo "Installing Ansible requirements: ${vm_fq_names}"    ; ansible-requirements --limit "${vm_fq_names}"
}
function vm-ansible-run-soe () {
    echo "Running SOE deploymemt tasks: ${vm_fq_names}"       ; ansible-soe          --limit "${vm_fq_names}" "$@"
}
function vm-ansible-run-soe-docker () {
    echo "Running SOE deploymemt tasks: ${vm_fq_names}"       ; ansible-soe          --limit "${vm_fq_names}" --skip-tags=docker-skip"$@"
}
