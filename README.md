# Infra

## Базовый образ cloud-init

Сборка выполняется в 2 этапа:

  1. [Ansible](https://www.ansible.com/) скачивает образ с сайта, добавляет `qemu-guest-agent`, создает ВМ (но не запускает), преобразует ВМ в шаблон.
  2. [Packer](https://www.packer.io/) клонирует шаблон из п.1, запускает ВМ, настраивает, преобразует ВМ в шаблон.

Разворачивание ВМ из образа выполняется с помощью [Terraform](https://www.terraform.io/).

## Пользователь для доступа к Proxmox API

```bash
pveum role add Provisioner -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Console VM.Monitor VM.PowerMgmt"

pveum user add hashicorp@pve

pveum aclmod / -user hashicorp@pve -role Provisioner

pveum user token add hashicorp@pve packer-terraform --privsep 0
```
