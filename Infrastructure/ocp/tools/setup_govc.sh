#!/bin/sh
rm /usr/local/sbin/govc
wget https://github.com/vmware/govmomi/releases/download/v0.24.0/govc_linux_amd64.gz
gunzip -d govc_linux_amd64.gz
chmod +x govc_linux_amd64
mv govc_linux_amd64 /usr/local/sbin/govc
export GOVC_URL="vcenter.local"
export GOVC_USERNAME="administrator@vcenter.local "
export GOVC_PASSWORD="asdfasfafas"
export GOVC_INSECURE="true"