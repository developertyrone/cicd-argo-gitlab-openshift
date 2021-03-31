# Overview
This version of installation is against the version on or above Openshift 4.6 and Vsphere User Provisioned Infrastructure (UPI)

Network Setup
1. Install Pfsense (follow the steps on 0_preparation)

Prerequisites
1. Vcenter credentials(In the lab we use admin role):
   Reference: https://vmware.github.io/vsphere-storage-for-kubernetes/documentation/vcp-roles.html#dynamic-provisioning
   Reference: https://vsphere-csi-driver.sigs.k8s.io/driver-deployment/prerequisites.html

2. Internet access for github.com to download GOVC

3. git clone https://github.com/developertyrone/cicd-argo-gitlab-openshift

4. cd /Infrastructure/ocp


# For Vsphere (ESXI) template installation (If you have vcenter console you can skip this step by adding template manually)
```
1. edit tools/setup_govc.sh
2. source ./tools/setup_govc.sh
```

# Import VM Template
```
1. make import-ova major=4.6 version=4.6.8 store=<datastore for the ova> 

1. make import-ova major=4.6 version=4.6.8 store=<datastore for the ova> host=
## To check resource pool
p.s. make list-vmware-resource-pool
```

# Install Terraform
1. make terraform-install-rhel

# Generate SSH Key
1. make sshkey-generate

# Create install-config.yaml
```
cat <<EOF > install-config.yaml
apiVersion: v1
baseDomain: ocp.local
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
metadata:
  name: dev
platform:
  vsphere:
    vcenter: <vcenter-name>
    username: <vcenter-user>
    password: <vcenter-password>
    datacenter: <vcenter-datacenter>
    defaultDatastore: <vcenter-datastore>
    folder = "<vcenter-vm-folder>"
fips: false 
pullSecret: '<pull-secret-key>'
sshKey: |
  $(cat $HOME/.ssh/ocp-key.pub)
EOF
```

# Install OC Tools
make install-oc-tools version=4.6

# Generate manifest for ocp installations
make generate-config

# Run Terraform
----
update file
vim clusters/4.6/variables.tf
update file 
vim clusters/4.6/terraform.tfvars
----
make terraform-init
make terraform-apply

# Check Installation
make installation-check

# Setup kubeconfig & approve csr
make update-kubeconfig
make approve-csr

# Add nodes
make add-worker-nodes