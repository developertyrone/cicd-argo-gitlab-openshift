approve-csr:
	sudo yum install jq -y
	oc  get csr -ojson | jq -r '.items[] | select(.status == {} ) | .metadata.name' | xargs oc adm certificate approve

remove-knownhost:
	ssh-keygen -R $(host)

kubeadmin-password:
	cat openshift/auth/kubeadmin-password

terraform-install-rhel:
	sudo dnf install -y dnf-plugins-core
	sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
	yum install terraform

terraform-install-fedora:
	sudo dnf install -y dnf-plugins-core
	sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/Fedora/hashicorp.repo
	yum install terraform

terraform-init:
	terraform -chdir=clusters/4.6 init

terraform-apply:
	terraform -chdir=clusters/4.6 apply -auto-approve

terraform-destroy:
	terraform -chdir=clusters/4.6 destroy -auto-approve

download-scripts:
	git clone https://github.com/developertyrone/ocp4.git

sshkey-generate:
	ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/ocp-key
	#eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/ocp-key

setup-govc:
	chmod +x ./tools/setup_govc.sh
	./tools/setup_govc.sh

generate-config:
	chmod +x ./tools/generate-configs.sh
	./tools/generate-configs.sh

installation-check:
	cd openshift; openshift-install wait-for install-complete --log-level debug

update-kubeconfig:
	mkdir -p ~/.kube
	cp openshift/auth/kubeconfig ~/.kube/config

install-oc-tools:
	git clone https://github.com/developertyrone/install-oc-tools
	./install-oc-tools/install-oc-tools.sh --$(channel) $(version)

import-ova:
	@if [ -z "$(host)" ]; then \
		govc import.ova -folder=$(folder) -ds=$(store) -name=rhcos-$(version) https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/$(major)/$(version)/rhcos-vmware.x86_64.ova; \
    else \
		govc import.ova -folder=$(folder) -ds=$(store) -host=$(host) -name=rhcos-$(version) https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/$(major)/$(version)/rhcos-vmware.x86_64.ova; \
    fi

add-worker-nodes:
	jq -r .infraID openshift/metadata.json

list-vmware-resource-pool:
	govc find / -type p

