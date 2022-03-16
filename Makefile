.PHONY: all help tools init fmt validate stage0-build stage0-destroy stage0-build-force stage1-build stage1-destroy stage1-build-force build build-force templates-destroy plan apply destroy show cluster

ifneq (,$(wildcard ./.env))
sinclude .env
export
endif

all: help

help:
	@echo "make commands"
	@echo "    tools                          Build and start local docker container 'infra-tools'"
	@echo "    init                           Init environment for Ansible, Packer and Terraform"
	@echo "    fmt                            Format Packer and Terraform files"
	@echo "    validate                       Validate Packer and Terraform files, lint Ansible files"
	@echo "    stage0-build                   Build stage0 Proxmox template from cloud-init image"
	@echo "    stage0-destroy                 ! Destroy stage0 template"
	@echo "    stage0-build-force             Recreate (Destroy + Build) stage0 template"
	@echo "    stage1-build                   Build stage1 Proxmox templates with Packer"
	@echo "    stage1-destroy                 ! Destroy stage1 templates"
	@echo "    stage1-build-force             Recreate (Destroy + Build) stage1 templates"
	@echo "    build                          Build all templates"
	@echo "    build-force                    Recreate (Destroy + Build) all templates"
	@echo "    templates-destroy              ! Destroy all templates"
	@echo "    plan                           [terraform] Show changes required by the current configuration"
	@echo "    apply                          [terraform] Create or update infrastructure"
	@echo "    destroy                        [terraform] Destroy previously-created infrastructure"
	@echo "    show                           [terraform] Show the current state or a saved plan"

tools:
	@make -C tools --no-print-directory

init:
	@cd ansible; ansible-galaxy install -r requirements.yml
	@cd packer; packer init .
	@cd terraform; terraform init

fmt:
	@cd packer; packer fmt .
	@cd terraform; terraform fmt

validate:
	@cd ansible; ansible-lint
	@cd packer; packer validate .
	@cd terraform; terraform validate

stage0-build:
	@cd ansible; ansible-playbook pve_template_build.yml

stage0-destroy:
	@cd ansible; ansible-playbook pve_template_destroy.yml -e "vm_id=${STAGE0_VM_ID}"

stage0-build-force: stage0-destroy
	@make stage0-build --no-print-directory

stage1-build:
	@cd packer; packer build .

stage1-destroy:
	@cd ansible; ansible-playbook pve_template_destroy.yml -e "vm_id=${STAGE1_VM_ID_BASE}"
	@cd ansible; ansible-playbook pve_template_destroy.yml -e "vm_id=${STAGE1_VM_ID_K8S}"

stage1-build-force: stage1-destroy
	@make stage1-build --no-print-directory

build:
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
	@cd terraform; terraform apply

destroy:
	@cd terraform; terraform destroy

show:
	@cd terraform; terraform show

cluster:
	@make init --no-print-directory
	@make build --no-print-directory
	@make apply --no-print-directory
