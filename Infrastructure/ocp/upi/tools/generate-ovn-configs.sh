#!/bin/sh
# A helper script for openshift-install

## ignition creation prep
rm -rf openshift
mkdir -p openshift
cp install-config.yaml openshift/
cd openshift

# create kubernetes manifests
openshift-install create manifests

# ensure masters are not schedulable
if [[ `uname` == 'Linux' ]] ; then
sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' manifests/cluster-scheduler-02-config.yml
else 
# macos sed will fail, this script requires `brew install gnu-sed`
gsed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' manifests/cluster-scheduler-02-config.yml
fi

# add custom ovn network config yaml file
cat <<EOF >>manifests/cluster-network-03-config.yml
apiVersion: operator.openshift.io/v1
kind: Network
metadata:
  name: cluster
spec: 
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  serviceNetwork:
  - 172.30.0.0/16
  defaultNetwork:
    type: OVNKubernetes 
    ovnKubernetesConfig: 
      mtu: 1400 
      genevePort: 6081 
EOF

## delete machines and machinesets
rm openshift/99_openshift-cluster-api_worker-machineset-0.yaml
rm openshift/99_openshift-cluster-api_master-machines-0.yaml
rm openshift/99_openshift-cluster-api_master-machines-1.yaml
rm openshift/99_openshift-cluster-api_master-machines-2.yaml

## ignition config creation
openshift-install create ignition-configs