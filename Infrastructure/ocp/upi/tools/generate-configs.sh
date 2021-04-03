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

## delete machines and machinesets
rm openshift/99_openshift-cluster-api_worker-machineset-0.yaml
rm openshift/99_openshift-cluster-api_master-machines-0.yaml
rm openshift/99_openshift-cluster-api_master-machines-1.yaml
rm openshift/99_openshift-cluster-api_master-machines-2.yaml

## ignition config creation
openshift-install create ignition-configs