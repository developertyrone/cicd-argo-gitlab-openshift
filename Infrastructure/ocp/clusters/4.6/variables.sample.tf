###########################
## OCP Cluster Vars

variable "cluster_slug" {
  type = string
}

variable "bootstrap_complete" {
  type    = string
  default = "false"
}

variable "enable_lb" {
  type    = string
  default = "false"
}

variable "enable_dns" {
  type    = string
  default = "false"
}
################
## VMware vars - unlikely to need to change between releases of OCP

variable "rhcos_template" {
  type = string
}

variable "vsphere_template_folder" {
  type = string
}

provider "vsphere" {
  #user           = yamldecode(file("~/.config/ocp/vsphere.yaml"))["vsphere-user"]
  #password       = yamldecode(file("~/.config/ocp/vsphere.yaml"))["vsphere-password"]
  #vsphere_server = yamldecode(file("~/.config/ocp/vsphere.yaml"))["vsphere-server"]

  user           = "administrator@vcenter.local"
  password       = "123QWEasd!"
  vsphere_server = "vcenter.local"


  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  #name = yamldecode(file("~/.config/ocp/vsphere.yaml"))["vsphere-dc"]
  name = "Datacenter"
}

data "vsphere_compute_cluster" "cluster" {
  #name          = yamldecode(file("~/.config/ocp/vsphere.yaml"))["vsphere-cluster"]
  name          = "MyHome"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "OCP4"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "masterstore" {
  name          = "S300_500_1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "workerstore" {
  name          = "S2000_1000_2"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "servicestore" {
  name          = "S2000_1000_2"
  datacenter_id = data.vsphere_datacenter.dc.id
}

##########
## Ignition

provider "ignition" {
  # https://www.terraform.io/docs/providers/ignition/index.html
  version = "1.2.1"
}

variable "ignition" {
  type    = string
  default = ""
}

#########
## Machine variables

variable "bootstrap_ignition_path" {
  type    = string
  default = ""
}

variable "master_ignition_path" {
  type    = string
  default = ""
}

variable "worker_ignition_path" {
  type    = string
  default = ""
}

variable "master_ips" {
  type    = list(string)
  default = []
}

variable "worker_ips" {
  type    = list(string)
  default = []
}

variable "bootstrap_ip" {
  type    = string
  default = ""
}

variable "loadbalancer_ip" {
  type    = string
  default = ""
}

variable "coredns_ip" {
  type    = string
  default = ""
}

variable "cluster_domain" {
  type = string
}

variable "machine_cidr" {
  type = string
}

variable "gateway" {
  type = string
}

variable "local_dns" {
  type = string
}

variable "public_dns" {
  type = string
}

variable "netmask" {
  type = string
}
