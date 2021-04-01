data "vsphere_virtual_machine" "template" {
  name          = var.rhcos_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

module "master" {
  source    = "../../modules/rhcos-static"
  count     = length(var.master_ips)
  name      = "${format("master%02s", count.index + 1)}.${var.cluster_slug}.${var.cluster_domain}"
  folder    = var.vsphere_template_folder
  datastore = data.vsphere_datastore.masterstore.id
  disk_size = 120 #120
  memory    = 16384 #16384
  num_cpu   = 4 #4
  ignition  = file(var.master_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.local_dns
  gateway        = var.gateway
  ipv4_address   = var.master_ips[count.index]
  netmask        = var.netmask
}

module "worker" {
  source    = "../../modules/rhcos-static"
  count     = length(var.worker_ips)
  name      = "${format("worker%02s", count.index + 1)}.${var.cluster_slug}.${var.cluster_domain}"
  folder    = var.vsphere_template_folder
  datastore = data.vsphere_datastore.workerstore.id
  disk_size = 120 #120
  memory    = 16384 #16384
  num_cpu   = 4 #4
  ignition  = file(var.worker_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.local_dns
  gateway        = var.gateway
  ipv4_address   = var.worker_ips[count.index]
  netmask        = var.netmask
  
}

module "bootstrap" {
  source    = "../../modules/rhcos-static"
  count     = var.bootstrap_complete ? 0 : 1
  name      = "bootstrap.${var.cluster_slug}.${var.cluster_domain}"
  folder    = var.vsphere_template_folder
  datastore = data.vsphere_datastore.servicestore.id
  disk_size = 100 #120
  memory    = 16384 #16384
  num_cpu   = 4 #4
  ignition  = file(var.bootstrap_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.local_dns
  gateway        = var.gateway
  ipv4_address   = var.bootstrap_ip
  netmask        = var.netmask
}

module "lb" {
  source = "../../modules/ignition_haproxy"
  #ssh_key_file  = [file("~/.ssh/id_ed25519.pub")]
  ssh_key_file  = [file("~/.ssh/ocp-key.pub")]
  lb_ip_address = var.loadbalancer_ip
  api_backend_addresses = flatten([
    var.bootstrap_ip,
    var.master_ips]
  )
  ingress = var.worker_ips
}

module "lb_vm" {
  source    = "../../modules/rhcos-static"
  count     = var.enable_lb ? 1 : 0
  name      = "haproxy.${var.cluster_slug}.${var.cluster_domain}"
  folder    = var.vsphere_template_folder
  datastore = data.vsphere_datastore.servicestore.id
  disk_size = 16
  memory    = 1024
  num_cpu   = 2
  ignition  = module.lb.ignition

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.public_dns
  gateway        = var.gateway
  ipv4_address   = var.loadbalancer_ip
  netmask        = var.netmask
}

output "ign" {
   value = module.lb.ignition
}

module "coredns" {
  source       = "../../modules/ignition_coredns"
  #ssh_key_file = [file("~/.ssh/id_ed25519.pub")]
  ssh_key_file  = [file("~/.ssh/ocp-key.pub")]

  cluster_slug    = var.cluster_slug
  cluster_domain  = var.cluster_domain
  coredns_ip      = var.coredns_ip
  bootstrap_ip    = var.bootstrap_ip
  loadbalancer_ip = var.loadbalancer_ip
  master_ips      = var.master_ips
  worker_ips      = var.worker_ips
}

module "dns_vm" {
  source    = "../../modules/rhcos-static"
  count     = var.enable_dns ? 1 : 0
  name      = "coredns.${var.cluster_slug}.${var.cluster_domain}"
  folder    = var.vsphere_template_folder
  datastore = data.vsphere_datastore.servicestore.id
  disk_size = 16
  memory    = 1024
  num_cpu   = 2
  ignition  = module.coredns.ignition

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.public_dns
  gateway        = var.gateway
  ipv4_address   = var.coredns_ip
  netmask        = var.netmask
}
