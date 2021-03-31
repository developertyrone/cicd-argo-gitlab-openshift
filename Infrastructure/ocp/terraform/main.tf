# =================== #
# Deploying VMware VM #
# =================== #
# Connect to VMware vSphere vCenter
provider "vsphere" {
user = var.vsphere-user
password = var.vsphere-password
vsphere_server = var.vsphere-vcenter
# If you have a self-signed cert
allow_unverified_ssl = var.vsphere-unverified-ssl
}
# Define VMware vSphere
data "vsphere_datacenter" "dc" {
name = var.vsphere-datacenter
}
data "vsphere_datastore" "datastore" {
name = var.vm-datastore
datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_compute_cluster" "cluster" {
name = var.vsphere-cluster
datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
name = var.vm-network
datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "template" {
name = "/${var.vsphere-datacenter}/vm/${var.vsphere-template-folder}/${var.vm-template-name}"
datacenter_id = data.vsphere_datacenter.dc.id
}
# Create VMs
resource "vsphere_virtual_machine" "vm" {
name = var.vm-name
resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
datastore_id = data.vsphere_datastore.datastore.id
num_cpus = var.vm-cpu
memory = var.vm-ram
guest_id = var.vm-guest-id
scsi_type = data.vsphere_virtual_machine.template.scsi_type
firmware  = var.vm-firmware
network_interface {
  network_id = data.vsphere_network.network.id
}
disk {
  label = "${var.vm-name}-disk"
  size  = data.vsphere_virtual_machine.template.disks.0.size
}
clone {
  template_uuid = data.vsphere_virtual_machine.template.id
  customize {
    timeout = 0
    
    linux_options {
      host_name = var.vm-hostname
      domain = var.vm-domain
    }
    
    network_interface {}
  }
 }
}