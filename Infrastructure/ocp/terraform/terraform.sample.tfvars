# VMware VMs configuration #
vm-count = "1"
vm-name = "GITLAB_RUNNER_UBUNTU"
# CENTOS8ANSIBLE, UBUNTU2004
vm-template-name = "UBUNTU2004"
vm-cpu = "4"
vm-ram = "8192"
# Vmware has provided a list of values of this guest id, https://code.vmware.com/apis/358/doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
# ubuntu64Guest, centos8_64Guest
vm-guest-id = "ubuntu64Guest"
# VMware vSphere configuration #
# VMware vCenter IP/FQDN
vsphere-vcenter = "192.168.11.15"
# VMware vSphere username used to deploy the infrastructure
vsphere-user = "svc@vcenter.local"
# VMware vSphere password used to deploy the infrastructure
vsphere-password = "123"
# Skip the verification of the vCenter SSL certificate (true/false)
vsphere-unverified-ssl = "true"
# vSphere datacenter name where the infrastructure will be deployed 
vsphere-datacenter = "Datacenter"
# vSphere cluster name where the infrastructure will be deployed
vsphere-cluster = "MyHome"
# vSphere template folder
vsphere-template-folder = "terraform-template"
# vSphere Datastore used to deploy VMs
# S600_256_1, S2000_1000_1
vm-datastore = "S600_256_1"
# vSphere Network used to deploy VMs 
vm-network = "VM Network"
# Linux virtual machine domain name
vm-domain = "sample.local"
# Linux hostnmae
vm-hostname = "cirunnerubuntu"
# Linux virtual machine firmware (bios[ubuntu],efi[centos])
vm-firmware = "bios"