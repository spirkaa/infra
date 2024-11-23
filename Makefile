.PHONY: all help cluster tools init init-upgrade cleanup fmt validate pve-api-user stage0-build stage0-destroy stage0-build-force stage1-build stage1-destroy stage1-build-force build build-force templates-destroy change plan apply refresh show destroy

ifneq (,$(wildcard ./.env))
sinclude .env
export
endif

K8S_NAMES = k8s-controlplane-01 k8s-controlplane-02 k8s-controlplane-03 k8s-worker-01 k8s-worker-02 k8s-worker-03 k8s-lb-01 k8s-lb-02
K8S_IPS = 01 02 03 11 12 13 21 22 40 54

all: help

help: ## Show this help
	@echo "Usage: make [target]"
	@echo "Targets:"
	@awk '/^[a-zA-Z0-9_-]+:.*?##/ { \
		helpMessage = match($$0, /## (.*)/); \
		if (helpMessage) { \
			target = $$1; \
			sub(/:/, "", target); \
			printf "  \033[36m%-20s\033[0m %s\n", target, substr($$0, RSTART + 3, RLENGTH); \
		} \
	}' $(MAKEFILE_LIST)

cluster:  ## All-in-one command for cluster deployment
	@make init --no-print-directory
	@make build --no-print-directory
	@sleep 10
	@cd terraform; terraform apply -auto-approve && terraform refresh

tools:  ## Build local docker image 'infra-tools' and start container
	@make -C tools --no-print-directory

init:  ## Init environment of Ansible, Packer and Terraform
	@packer version
	@terraform version
	@ansible --version
	@pip install --no-cache-dir -r requirements.txt
	@cd ansible; ansible-galaxy role install -r requirements.yml; ansible-galaxy collection install --no-cache -r requirements.yml
	@cd packer; packer init .
	@cd terraform; terraform init -backend-config="access_key=${TF_ACCESS_KEY}" -backend-config="secret_key=${TF_SECRET_KEY}"

init-upgrade:  ## Init/upgrade environment of Ansible, Packer and Terraform
	@packer version
	@terraform version
	@ansible --version
	@pip install --no-cache-dir -U -r requirements.txt
	@cd ansible; ansible-galaxy role install --force -r requirements.yml; ansible-galaxy collection install --force --no-cache -r requirements.yml
	@cd packer; packer init -upgrade .
	@cd terraform; terraform init -upgrade -backend-config="access_key=${TF_ACCESS_KEY}" -backend-config="secret_key=${TF_SECRET_KEY}"

cleanup:  ## Cleanup environment of Ansible, Packer and Terraform
	@rm -rf ~/.ansible/roles
	@rm -rf ~/.ansible/collections
	@rm -rf terraform/.terraform
	@rm -rf ~/.config/packer

fmt:  ## Format Packer and Terraform files
	@cd packer; packer fmt .
	@cd terraform; terraform fmt

validate:  ## Validate Packer and Terraform files, lint Ansible files
	@cd ansible; ansible-lint
	@cd packer; packer validate .
	@cd terraform; terraform validate

pve-api-user:  ## Create Proxmox API user for Packer and Terraform
	@cd ansible; ansible-playbook pve_api_user.yml -e "pve_host=${PROXMOX_NODE}"

stage0-build:  ## Build stage0 Proxmox template from cloud-init image
	@cd ansible; ansible-playbook pve_template_build.yml -e "pve_host=${PROXMOX_NODE}"

stage0-destroy:  ## Destroy stage0 template
	@cd ansible; ansible-playbook pve_template_destroy.yml -e "pve_host=${PROXMOX_NODE}" -e "pve_template_vmid=${STAGE0_VM_ID}"

stage0-build-force: stage0-destroy  ## Recreate (Destroy + Build) stage0 template
	@make stage0-build --no-print-directory

stage1-build:  ## Build stage1 Proxmox templates with Packer
	@cd packer; packer build .

stage1-destroy:  ## Destroy stage1 templates
	@cd ansible; ansible-playbook pve_template_destroy.yml -e "pve_host=${PROXMOX_NODE}" -e "pve_template_vmid=${STAGE1_VM_ID_BASE}"
	@cd ansible; ansible-playbook pve_template_destroy.yml -e "pve_host=${PROXMOX_NODE}" -e "pve_template_vmid=${STAGE1_VM_ID_K8S}"

stage1-build-force: stage1-destroy  ## Recreate (Destroy + Build) stage1 templates
	@make stage1-build --no-print-directory

build:  ## Build all templates
	@make pve-api-user --no-print-directory
	@make stage0-build --no-print-directory
	@make stage1-build --no-print-directory

build-force:  ## Recreate (Destroy + Build) all templates
	@make stage0-build-force --no-print-directory
	@make stage1-build-force --no-print-directory

templates-destroy:  ## Destroy all templates
	@make stage0-destroy --no-print-directory
	@make stage1-destroy --no-print-directory

change:  ## [terraform] Apply changes to specific target
	@cd terraform; terraform apply -target=proxmox_vm_qemu.k8s_worker[\"k8s-worker-03\"]

replace:  ## [terraform] Replace specific target
	@cd terraform; terraform apply -replace=proxmox_vm_qemu.k8s_worker[\"k8s-worker-03\"]

plan:  ## [terraform] Show changes required by the current configuration
	@cd terraform; terraform plan

apply:  ## [terraform] Create or update infrastructure
	@cd terraform; terraform apply && terraform refresh

refresh:  ## [terraform] Update the state to match remote systems
	@cd terraform; terraform refresh

show:  ## [terraform] Show the current state or a saved plan
	@cd terraform; terraform show

destroy:  ## [terraform] Destroy previously-created infrastructure
	@echo "! ! ! THIS IS A DANGEROUS ACTION ! ! !"
	@echo "If you know 100% what are you doing, edit the Makefile and uncomment these lines:"
	@echo ""
	# @cd terraform; terraform destroy
	# @for name in $(K8S_NAMES); do \
		# ssh-keygen -f ~/.ssh/known_hosts -R $$name; \
	# done
	# @for ip in $(K8S_IPS); do \
		# ssh-keygen -f ~/.ssh/known_hosts -R 192.168.13.2$$ip; \
	# done
