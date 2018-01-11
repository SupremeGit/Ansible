# Ansible

Some ansible playbooks to setup a basic SOE on various linux distributions, currently: 
 * fedora 26
 * fedora (27) 
 * centos 7.4 
 * ubuntu 17.04 desktop/server.

The virt folder contains several tools to test the ansible playbooks on supported distributions:

 * soe-libvirt: Templates & scripts using libvirt/virsh to test on VMs.

 * soe-docker:  
   * Dockerfile & scripts using Docker to build images & manage containers. 
   * Currently only creates an image to test fedora.

