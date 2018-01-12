# Ansible

Some ansible playbooks to setup a basic SOE on various linux distributions, currently: 
 * Fedora 26
 * Fedora (27) 
 * CentOS 7.4 
 * Ubuntu 17.04 desktop/server.


The ansible playbooks currently perform the following tasks:
 * setup ssh keys and dependencies (python2-dnf, python-apt) for full ansible operation.
 * setup epel, Puppet, and local base/update repositories
 * installs key apps: ssh server, git, collectd, nagios nrpe plugin executor, CockPit management console
 * configures firewall to allow monitoring & management via nagios, collectd, CockPit
 * starts services, including nagios, collectd, CockPit.
 * for Fedora, installs Xfce desktop group & sets default target to graphical
 * installs cronjob to periodically pulldown a git Puppet repository & run Puppet to deploy configuration updates committed to the git repository. This cronjob is not currently enabled, but I intend to enable it when testing some Puppet.


The virt subfolder contains several tools to test the ansible playbooks on supported distributions:
 * soe-libvirt: Templates & scripts using libvirt/virsh to test on VMs.
   * vm-template folder: contains a master-template.xml file, which is a libvirt xml file for creating VMs. To create a new VM, copy the template, and in the copy, edit the VM name, description, and path to the disk image.
   * vm-soe.vorpal: contains a set of 9 libvirt VM xml files (created from the master template), describing 9 VMs I've setup with base OS installs (Fedora, CentOS, Ubuntu Desktop/Server)
   * soe-vm-control.sh - interface to simplify virsh (libvirt) commands to control VMs. This script takes care of defining, undefining, starting, shutting down, & destroying VMs, and with manipulating VM image files so the playbooks can be tested on fresh images.
   * soe-build.sh - uses the soe-vm-control script to manage multiple VMs, in this case, the 9 VMs defined in the vm-soe.vorpal folder. Testing the SOE build involves re-imaging the VMs, starting them, wait for them to fully boot, and then running the ansible soe build playbooks on all images in parallel.

 * soe-docker:
   * Uses a similar scheme to soe-libvirt:
     * vm-docker.vorpal folder with configuration (Dockerfile, docker-compose.yml, monit config, scripts) to build Docker images of the different targeted distributions.
     * soe-docker-control.sh and soe-docker-build.sh, use Docker CLI to to manage building the Docker images and sequencing operations on images & containers.
   * Currently only creates an image to test fedora. 
   * Other distros will be added shortly, once things are working nicely for Fedora.
   * I'll probably add Vagrant support shortly, for more control
