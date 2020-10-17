# VMware VMs configuration #
vm-count = "1"
vm-name = "GITLAB"
vm-template-name = "<Your template name>"
vm-cpu = "4"
vm-ram = "8192"
# Vmware has provided a list of values of this guest id, https://code.vmware.com/apis/358/doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
vm-guest-id = "centos8_64Guest"
# VMware vSphere configuration #
# VMware vCenter IP/FQDN
vsphere-vcenter = "<Your IP>"
# VMware vSphere username used to deploy the infrastructure
vsphere-user = "<VCenter Username>"
# VMware vSphere password used to deploy the infrastructure
vsphere-password = "<VCenter Password>"
# Skip the verification of the vCenter SSL certificate (true/false)
vsphere-unverified-ssl = "true"
# vSphere datacenter name where the infrastructure will be deployed 
vsphere-datacenter = "Datacenter"
# vSphere cluster name where the infrastructure will be deployed
vsphere-cluster = "MyHome"
# vSphere template folder
vsphere-template-folder = "terraform-template"
# vSphere Datastore used to deploy VMs 
vm-datastore = "<VM datastore>"
# vSphere Network used to deploy VMs 
vm-network = "VM Network"
# Linux virtual machine domain name
vm-domain = "<VM domain>"
# Linux hostnmae
vm-hostname = "<VM hostname>"
# Linux virtual machine firmware
vm-firmware = "efi"



