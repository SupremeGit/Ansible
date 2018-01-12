# Ansible

Some ansible playbooks to setup a basic SOE on various linux distributions, currently: 
 * Fedora 26
 * Fedora (27) 
 * CentOS 7.4 
 * Ubuntu 17.04 desktop/server.

The ansible playbooks currently perform the following tasks:
 * setup ssh keys and dependencies (python2-dnf, python-apt) for full ansible operation.
 * setup epel, Puppet, and (for Fedora) local repositories
 * install key apps: ssh server, git, strace, emacs, and monitoring/management
 * sets up monitoring & management via collectd, nagios nrpe plugin executor, CockPit management console (open firewall ports, configure & start services)
 * install bashrc, bashrc aliases, and .emacs configuration, for a less-painful sysadmin experience
 * for Fedora, install Xfce desktop group & set default systemd target to graphical (other distros will follow when I've setup local repos for them too, to speed this step up)
 * install cronjob to periodically git pull a Puppet repository & run Puppet to deploy updates. This cronjob is not currently enabled, but I intend to enable it when testing some Puppet.


The virt subfolder contains several tools to test the ansible playbooks on supported distributions:
 * soe-libvirt: Templates & scripts using libvirt/virsh to test ansible playbooks on VMs.
   * vm-template folder: contains a template libvirt xml file for creating VMs. To create a new VM, copy, then edit the VM name, description, and path to disk image.
   * vm-soe.vorpal: contains a set of 9 libvirt VM xml files (created from the template), describing 9 VMs I've setup with base OS installs (Fedora, CentOS, Ubuntu Desktop/Server)
   * soe-vm-control.sh - interface to simplify virsh (libvirt) commands to control VMs. This script takes care of defining, undefining, starting, shutting down, & destroying VMs, and with manipulating VM image files so the playbooks can be repeatedly tested on fresh images.
   * soe-build.sh - uses the soe-vm-control script to manage multiple VMs, and tests the SOE playbooks on all VMs in parallel.

 * soe-docker:
   * Uses a similar scheme to soe-libvirt:
     * vm-docker.vorpal folder with configuration (Dockerfile, docker-compose.yml, monit config, scripts) to build Docker images of targeted distributions.
     * soe-docker-control.sh and soe-docker-build.sh - use Docker CLI to to build Docker images and sequence operations on images & containers.
   * Currently only creates an image to test fedora. 
   * Other distros will be added shortly, once things are working nicely for Fedora.
   * I'll add Vagrant support shortly, for more control
