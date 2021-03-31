## Node IPs
loadbalancer_ip = "10.0.0.211"
coredns_ip = "10.0.0.254"
bootstrap_ip = "10.0.0.200"
master_ips = ["10.0.0.201", "10.0.0.202", "10.0.0.203"]
worker_ips = ["10.0.0.204", "10.0.0.205", "10.0.0.206"]

## Cluster configuration
rhcos_template = "rhcos-4.6.8"
vsphere_template_folder = "terraform-template"
cluster_slug = "dev"
cluster_domain = "ocp.local"
machine_cidr = "10.128.0.0/14"
netmask ="255.252.0.0"
enable_lb = true
enable_dns = false


## DNS
local_dns = "10.0.0.254" # probably the same as coredns_ip
public_dns = "10.0.0.254" # Internal DNS
gateway = "10.0.0.254" # Internal Gateway

## Ignition paths
## Expects `openshift-install create ignition-configs` to have been run
## probably via generate-configs.sh
bootstrap_ignition_path = "../../openshift/bootstrap.ign"
master_ignition_path = "../../openshift/master.ign"
worker_ignition_path = "../../openshift/worker.ign"