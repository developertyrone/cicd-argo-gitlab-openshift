# Proper CICD with Openshift, ArgoCD & Gitlab in Vsphere


# OS Templates

To provide repeatable OS Creation, the following steps are suggested to produce a golden image.

Either Vsphere/Hyperv/RHV will do

In this example we leverage the terraform and vsphere
2vCPU, 4GB ram, 100 GB harddisk(thin provisioning)

## CENTOS 8

1. Install CENTOS
2. dnf update
3. disable SELINUX
4. setup ansible account, ssh-genkey, copy the key
5. setup ansible account as sudoer
6. convert the VM to template (URL needed)

# Create VMs
There are several way to achieve the VM creation

Create Vsphere role for Terraform Provisioning
Terraform:
(GithubURL)

Reference: https://medium.com/@gmusumeci/deploying-vmware-vsphere-virtual-machines-with-packer-terraform-d0211f72b7f5

# Install Gitlab on CentOS8

## Manual Installation

## Install with Ansible