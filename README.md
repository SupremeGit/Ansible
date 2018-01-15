# Ansible
Some Ansible playbooks & tools to develop a basic SOE (standard operating environment). 

## Supported distributions: 
 * Fedora 26
 * Fedora (27) 
 * CentOS 7.4 
 * Ubuntu 17.04 desktop/server.

## Goal:
The playbooks don't aim to produce anything like a fully finished SOE. It's more intended as a foundation which:
 * sets up basic monitoring & configuration tools (eg Nagios, Collectd, CockPit, Puppet), to gain some initial visibility & control over machines
 * can be easily extended, either with more Ansible, or, if you prefer, Puppet
 * provides tools to easily test any changes or additions you might like to make, vs any OS you might like to target.

## Functionality:
The Ansible playbooks currently perform the following tasks:
 * setup ssh keys and ansible dependencies (python2-dnf, python-apt)
 * setup extra repositories (e.g. epel, Puppet), and (for Fedora) local repositories to accelerate installs
 * install key apps, eg: git, emacs, Puppet (easy to add more)
 * configure monitoring & management: collectd, Nagios nrpe plugin executor, CockPit management console
 * install bashrc, bashrc aliases, and .emacs configuration, for a less-painful sysadmin experience
 * install Xfce desktop group & set default systemd target to graphical
 * install cronjob to periodically git pull a local Puppet repository & run Puppet to deploy local updates. This cronjob is not currently enabled, but I intend to enable it when testing some Puppet.

## Testing:
The virt subfolder contains several testing tools:

### Libvirt:
 * soe-libvirt: Templates & scripts using libvirt/virsh to test ansible playbooks on VMs:
   * vm-template folder: contains a template libvirt VM xml file for creating VMs. To create a new VM: copy, then edit the VM name, description, and path to disk image
   * vm-soe.vorpal: contains a set of 9 libvirt VM xml files (created from the template), describing 9 VMs I've setup with base OS installs (Fedora, CentOS, Ubuntu Desktop/Server)
   * soe-vm-control.sh - interface to simplify virsh (libvirt) control of VMs
   * soe-build.sh - uses the soe-vm-control script to manage multiple VMs, and sequence operations: define & boot up fresh vms, test SOE playbooks on all VMs in parallel, then shutdown & undefine the VMs.

### Docker
 * soe-docker:
   * Uses a similar scheme to soe-libvirt:
     * vm-docker.vorpal folder with configuration (Dockerfile, docker-compose.yml, monit config, scripts) to build Docker images of targeted distributions
     * soe-docker-control.sh and soe-docker-build.sh - use Docker CLI to to build Docker images and sequence operations on images & containers
   * Currently only creates an image to test Fedora.
   
### Vagrant
 * Vagrant support for Docker & VirtualBox will be coming at some point, but for now, the control & build scripts I've done are sufficient.
