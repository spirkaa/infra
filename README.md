# Infra

## Компоненты кластера Kubernetes

### База

* [runc](https://github.com/opencontainers/runc/releases)
* [cni](https://github.com/containernetworking/plugins/releases)
* [containerd](https://github.com/containerd/containerd/releases)
* [crictl](https://github.com/kubernetes-sigs/cri-tools/releases)
* [nerdctl](https://github.com/containerd/nerdctl/releases)
* [kubernetes](https://kubernetes.io/releases/)

### Сеть

* [Calico](https://github.com/projectcalico/calico)
* [MetalLB](https://github.com/metallb/metallb)
* [ingress-nginx](https://github.com/kubernetes/ingress-nginx)
* [cert-manager](https://github.com/cert-manager/cert-manager) + [cert-manager-webhook-selectel](https://github.com/selectel/cert-manager-webhook-selectel)

### Хранилище

* [Longhorn](https://github.com/longhorn/longhorn)

### GitOps

* [ArgoCD](https://github.com/argoproj/argo-cd) + [argocd-lovely-plugin](https://github.com/crumbhole/argocd-lovely-plugin)
* [Vault](https://github.com/hashicorp/vault) + [vault-bootstrap](https://github.com/spirkaa/vault-bootstrap)

## Запуск

### Требования

* Сервер Proxmox
* Клиент Linux/macOS с установленным git и docker для запуска контейнера с утилитами

### Пользователь для API Proxmox

В консоли сервера Proxmox выполнить команды и сохранить вывод последней.

`pveum role add Provisioner -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Console VM.Monitor VM.PowerMgmt"`

`pveum user add hashicorp@pve`

`pveum aclmod / -user hashicorp@pve -role Provisioner`

`pveum user token add hashicorp@pve packer-terraform --privsep 0`

### Алгоритм запуска

1. Клонировать репозиторий

    `git clone --recurse-submodules https://github.com/spirkaa/infra`

1. Перейти в каталог

    `cd infra`

1. Скопировать env-файл

    `cp .env.example .env`

1. Указать необходимые значения в env-файле

    `nano .env`

1. Собрать образ с утилитами и запустить контейнер

    `make tools`

1. Запустить развертывание кластера

    `make cluster`

## Базовый шаблон ВМ (cloud-init)

Подготовка выполняется в 2 этапа:

1. [Ansible](https://www.ansible.com/) скачивает образ Ubuntu Cloud с сайта, с помощью `virt-customize` устанавливает в него пакет `qemu-guest-agent`, создает ВМ и импортирует образ (но не запускает), преобразует ВМ в шаблон. Готовый шаблон должен оставаться в системе для идемпотентности.
2. [Packer](https://www.packer.io/) клонирует шаблон из п.1, запускает, настраивает с помощью Ansible, преобразует в шаблон.

Разворачивание ВМ из шаблона выполняется с помощью [Terraform](https://www.terraform.io/).
