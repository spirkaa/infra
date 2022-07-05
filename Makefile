.PHONY: all help tools init fmt validate cleanup pve-api-user stage0-build stage0-destroy stage0-build-force stage1-build stage1-destroy stage1-build-force build build-force templates-destroy plan apply refresh destroy show cluster

ifneq (,$(wildcard ./.env))
sinclude .env
export
endif

K8S_NAMES = k8s-controlplane-01 k8s-controlplane-02 k8s-controlplane-03 k8s-worker-01 k8s-worker-02 k8s-worker-03 k8s-lb-01 k8s-lb-02
K8S_IPS = 01 02 03 11 12 13 21 22 40 54

all: help

help:
	@echo "    cluster                        All-in-one command for cluster deployment"
	@echo ""
	@echo "    tools                          Build local docker image 'infra-tools' and start container"
	@echo "    init                           Init environment of Ansible, Packer and Terraform"
	@echo "    init-upgrade                   Init/upgrade environment of Ansible, Packer and Terraform"
	@echo "    fmt                            Format Packer and Terraform files"
	@echo "    validate                       Validate Packer and Terraform files, lint Ansible files"
	@echo "    cleanup                        Cleanup init"
	@echo ""
	@echo "    pve-api-user                   Create Proxmox API user for Packer and Terraform"
	@echo "    stage0-build                   Build stage0 Proxmox template from cloud-init image"
	@echo "    stage0-destroy                 ! Destroy stage0 template"
	@echo "    stage0-build-force             Recreate (Destroy + Build) stage0 template"
	@echo "    stage1-build                   Build stage1 Proxmox templates with Packer"
	@echo "    stage1-destroy                 ! Destroy stage1 templates"
	@echo "    stage1-build-force             Recreate (Destroy + Build) stage1 templates"
	@echo "    build                          Build all templates"
	@echo "    build-force                    Recreate (Destroy + Build) all templates"
	@echo "    templates-destroy              ! Destroy all templates"
	@echo ""
	@echo "    plan                           [terraform] Show changes required by the current configuration"
	@echo "    apply                          [terraform] Create or update infrastructure"
	@echo "    refresh                        [terraform] Update the state to match remote systems"
	@echo "    destroy                        [terraform] Destroy previously-created infrastructure"
	@echo "    show                           [terraform] Show the current state or a saved plan"

tools:
	@make -C tools --no-print-directory

init:
	@packer version
	@terraform version
	@ansible --version
	@pip install --no-cache-dir -r requirements.txt
	@cd ansible; ansible-galaxy role install -r requirements.yml; ansible-galaxy collection install --no-cache -r requirements.yml
	@cd packer; packer init .
	@cd terraform; terraform init -backend-config="access_key=${TF_ACCESS_KEY}" -backend-config="secret_key=${TF_SECRET_KEY}"

init-upgrade:
	@packer version
	@terraform version
	@ansible --version
	@pip install --no-cache-dir -U -r requirements.txt
	@cd ansible; ansible-galaxy role install --force -r requirements.yml; ansible-galaxy collection install --force --no-cache -r requirements.yml
	@cd packer; packer init -upgrade .
	@cd terraform; terraform init -upgrade -backend-config="access_key=${TF_ACCESS_KEY}" -backend-config="secret_key=${TF_SECRET_KEY}"

fmt:
	@cd packer; packer fmt .
	@cd terraform; terraform fmt

validate:
	@cd ansible; ansible-lint
	@cd packer; packer validate .
	@cd terraform; terraform validate

cleanup:
	@rm -rf ~/.ansible/roles
	@rm -rf ~/.ansible/collections
	@rm -rf terraform/.terraform
	@rm -rf ~/.config/packer

pve-api-user:
	@cd ansible; ansible-playbook pve_api_user.yml

stage0-build:
	@cd ansible; ansible-playbook pve_template_build.yml

stage0-destroy:
	@cd ansible; ansible-playbook pve_template_destroy.yml -e "pve_template_vmid=${STAGE0_VM_ID}"

stage0-build-force: stage0-destroy
	@make stage0-build --no-print-directory

stage1-build:
	@cd packer; packer build .

stage1-destroy:
	@cd ansible; ansible-playbook pve_template_destroy.yml -e "pve_template_vmid=${STAGE1_VM_ID_BASE}"
	@cd ansible; ansible-playbook pve_template_destroy.yml -e "pve_template_vmid=${STAGE1_VM_ID_K8S}"

stage1-build-force: stage1-destroy
	@make stage1-build --no-print-directory

build:
	@make pve-api-user --no-print-directory
	@make stage0-build --no-print-directory
	@make stage1-build --no-print-directory

build-force:
	@make stage0-build-force --no-print-directory
	@make stage1-build-force --no-print-directory

templates-destroy:
	@make stage0-destroy --no-print-directory
	@make stage1-destroy --no-print-directory

plan:
	@cd terraform; terraform plan

apply:
	@cd terraform; terraform apply && terraform refresh

refresh:
	@cd terraform; terraform refresh

destroy:
	@cd terraform; terraform destroy
	@for name in $(K8S_NAMES); do \
		ssh-keygen -f ~/.ssh/known_hosts -R $$name; \
	done
	@for ip in $(K8S_IPS); do \
		ssh-keygen -f ~/.ssh/known_hosts -R 192.168.13.2$$ip; \
	done

show:
	@cd terraform; terraform show

cluster:
	@make init --no-print-directory
	@make build --no-print-directory
	@sleep 10
	@cd terraform; terraform apply -auto-approve && terraform refresh

cluster-upgrade:
	@cd ansible; ansible-playbook -i inventories/k8s -f 1 playbooks/k8s_cluster_upgrade.yml -v

test-plan:
	@cd terraform/test; terraform plan

test-apply:
	@cd terraform/test; terraform apply

test-destroy:
	@cd terraform/test; terraform destroy
	@ssh-keygen -f ~/.ssh/known_hosts -R 192.168.13.91

test-show:
	@cd terraform/test; terraform show

change:
	@cd terraform; terraform apply -target=proxmox_vm_qemu.k8s_controlplane[\"k8s-controlplane-03\"]
