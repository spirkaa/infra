.PHONY: all help init fmt validate build-stage0 build-stage0-force build-stage1 build plan apply destroy

ifneq (,$(wildcard ./.env))
sinclude .env
export
endif

all: help

help:
	@echo "make commands"
	@echo "    init                           Init packer and terraform"
	@echo "    fmt                            Format packer and terraform files"
	@echo "    validate                       Validate packer and terraform files"
	@echo "    build-stage0                   [ansible] Prepare Proxmox template from cloud-init image"
	@echo "    build-stage0-force             [ansible] Prepare Proxmox template from cloud-init image (force)"
	@echo "    build-stage1                   [packer] Provision Proxmox template from stage0"
	@echo "    build                          Build stage0 and stage1"
	@echo "    plan                           [terraform] Show changes required by the current configuration"
	@echo "    apply                          [terraform] Create or update infrastructure"
	@echo "    destroy                        [terraform] Destroy previously-created infrastructure"

init:
	@cd packer; packer init .
	@cd terraform; terraform init

fmt:
	@cd packer; packer fmt .
	@cd terraform; terraform fmt

validate:
	@cd packer; packer validate .
	@cd terraform; terraform validate

build-stage0:
	@cd ansible; ansible-playbook build_proxmox_template.yml

build-stage0-force:
	@cd ansible; ansible-playbook build_proxmox_template.yml -e "force=yes"

build-stage1:
	@cd packer; packer build .

build:
	@make build-stage0 --no-print-directory
	@make build-stage1 --no-print-directory

plan:
	@cd terraform; terraform plan

apply:
	@cd terraform; terraform apply

destroy:
	@cd terraform; terraform destroy
