# Infra (Home Kubernetes)

Конфигурация моего домашнего кластера Kubernetes с использованием методологий [Infrastructure-as-Code](https://www.redhat.com/en/topics/automation/what-is-infrastructure-as-code-iac) и [GitOps](https://www.weave.works/technologies/gitops/).

* Предыдущая версия конфигурации (без k8s, на основе Docker внутри LXC) - [spirkaa/ansible-homelab](https://github.com/spirkaa/ansible-homelab).
* Для вдохновения можно посмотреть, как делают другие - [awesome-home-kubernetes](https://github.com/k8s-at-home/awesome-home-kubernetes).

## Обзор

Основные компоненты разделены по директориям:

* [ansible](ansible) - роли для настройки шаблонов ВМ и первоначального запуска кластера c помощью kubeadm.
* [сluster](cluster) - конфигурация приложений, разворачиваемых с помощью ArgoCD.
* [packer](packer) - создание шаблонов ВМ.
* [terraform](terraform) - запуск, настройка и управление жизненным циклом ВМ в кластере.

### Железо

Хосты работают на Proxmox в составе кластера.

* 1x Custom NAS (Fractal Design Define R6, Corsair RM650x)
  * Intel Xeon E3-1230 v5
  * 64GB DDR4 ECC UDIMM
  * 512GB NVMe SSD (lvm)
  * 10x 8 TB HDD (mergerfs+snapraid)
  * 2x 12 TB HDD (zfs mirror)

* 2x Lenovo IdeaCentre G5-14IMB05
  * Intel Core i5-10400
  * 32GB DDR4
  * 512GB NVMe SSD (lvm)

* 1x Ubiquiti EdgeRouter X
* 1x Ubiquiti EdgeSwitch 24 Lite
* 1x CyberPower CP900EPFC

### Внешние сервисы

* Бесплатный DNS-хостинг от [selectel](https://selectel.ru/services/additional/dns/), потому что есть API и вебхук для cert-manager.
* VPS от [sale-dedic](https://sale-dedic.com/?from=38415).

## Компоненты кластера Kubernetes

### Виртуальные машины

* 3x Control Plane (2 vCPU, 4 GB)
* 3x Worker (4/6 vCPU, 16 GB)
* 2x Control Plane Load Balancer (1 vCPU, 1GB)

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
* [Keepalived](https://www.keepalived.org) + [HAProxy](https://www.haproxy.com) вне кластера для Control Plane

### Хранилище

* [Longhorn](https://github.com/longhorn/longhorn)
* [minio](https://github.com/minio/minio)
* NFS

### Observability (логи, метрики, трейсы)

* [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts)
  * [Prometheus](https://github.com/prometheus/prometheus)
  * [Alertmanager](https://github.com/prometheus/alertmanager) + [alertmanager-notifier](https://github.com/ix-ai/alertmanager-notifier)
  * [Grafana](https://github.com/grafana/grafana)
* [loki-stack](https://github.com/grafana/helm-charts/tree/main/charts/loki-stack)
  * [Loki](https://github.com/grafana/loki)
  * [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/)
* [metrics-server](https://github.com/kubernetes-sigs/metrics-server)

### GitOps

* [ArgoCD](https://github.com/argoproj/argo-cd) + [argocd-lovely-plugin](https://github.com/crumbhole/argocd-lovely-plugin) + [argocd-vault-plugin](https://github.com/argoproj-labs/argocd-vault-plugin)
* [Renovate](https://github.com/renovatebot/renovate)

### Secrets

* [Vault](https://github.com/hashicorp/vault) + [vault-bootstrap](https://github.com/spirkaa/vault-bootstrap)
* [external-secrets](https://github.com/external-secrets/external-secrets/)

### Auth

* [authentik](https://github.com/goauthentik/authentik)
* [dex](https://github.com/dexidp/dex)
* [oauth2-proxy](https://github.com/oauth2-proxy/oauth2-proxy)
* [teleport](https://github.com/gravitational/teleport)

### Backup

* [velero](https://github.com/vmware-tanzu/velero)

### Утилиты

* [descheduler](https://github.com/kubernetes-sigs/descheduler)
* [Kured](https://github.com/weaveworks/kured)
* [Reloader](https://github.com/stakater/Reloader)

## Пользовательские приложения

* [Portainer](https://github.com/portainer/portainer)
* [Dashy](https://github.com/lissy93/dashy)
* [Vikunja](https://vikunja.io/)
* [Vaultwarden](https://github.com/dani-garcia/vaultwarden)
* [Nextcloud](https://github.com/nextcloud/server)
* [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)
* [Bazarr](https://github.com/morpheus65535/bazarr)
* [Radarr](https://github.com/Radarr/Radarr)
* [Sonarr](https://github.com/Sonarr/Sonarr)
* [Lidarr](https://github.com/lidarr/Lidarr)
* [Prowlarr](https://github.com/Prowlarr/Prowlarr)
* [Jackett](https://github.com/Jackett/Jackett)
* [Monitorrent](https://github.com/werwolfby/monitorrent)
* [Deluge](https://github.com/binhex/arch-delugevpn)
* [Tautulli](https://github.com/Tautulli/Tautulli)
* [Ombi](https://github.com/Ombi-app/Ombi)
* [UniFi Network](https://help.ui.com/hc/en-us/categories/200320654)
* [docker-mailserver](https://github.com/docker-mailserver/docker-mailserver)

## Запуск кластера

### Требования

* Сервер Proxmox
* Клиент Linux с установленными `git` и `docker` для запуска контейнера с утилитами

### Пользователь для API Proxmox

Создать пользователя можно с помощью роли [pve/api_user](ansible/roles/pve/api_user) или вручную, выполнив команды в консоли сервера Proxmox и сохранив вывод последней.

`pveum role add Provisioner -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Pool.Audit Sys.Audit Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Console VM.Monitor VM.PowerMgmt"`

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

1. [Ansible](https://www.ansible.com/) скачивает образ [Ubuntu Cloud](https://cloud-images.ubuntu.com/releases/jammy/), с помощью `virt-customize` устанавливает в него пакет `qemu-guest-agent`, создает ВМ в Proxmox и импортирует образ (но не запускает), преобразует ВМ в шаблон. Готовый шаблон должен оставаться в системе для идемпотентности.
1. [Packer](https://www.packer.io/) клонирует шаблон из п.1, запускает ВМ, настраивает с помощью Ansible, преобразует в шаблон.

Разворачивание ВМ из шаблона выполняется с помощью [Terraform](https://www.terraform.io/).

## Выключение/перезагрузка ноды

1. Снять нагрузку

    ```bash
    kubectl drain k8s-worker-01 --ignore-daemonsets --delete-emptydir-data --pod-selector='app!=csi-attacher,app!=csi-provisioner'
    ```

1. Настроить заглушку уведомлений в Alertmanager

1. После включения разрешить нагрузку

    ```bash
    kubectl uncordon k8s-worker-01
    ```

## Замена ноды

1. Снять нагрузку

    ```bash
    kubectl drain k8s-controlplane-02 --ignore-daemonsets --delete-emptydir-data --pod-selector='app!=csi-attacher,app!=csi-provisioner'
    ```

1. Удалить из k8s

    ```bash
    kubectl delete node k8s-controlplane-02
    ```

1. Удалить из etcd (для control plane)

    ```bash
    kubectl -n kube-system exec -it etcd-k8s-controlplane-03 -- sh -c 'ETCDCTL_API=3 etcdctl --cacert="/etc/kubernetes/pki/etcd/ca.crt" --cert="/etc/kubernetes/pki/etcd/server.crt" --key="/etc/kubernetes/pki/etcd/server.key" member list -w table'
    kubectl -n kube-system exec -it etcd-k8s-controlplane-03 -- sh -c 'ETCDCTL_API=3 etcdctl --cacert="/etc/kubernetes/pki/etcd/ca.crt" --cert="/etc/kubernetes/pki/etcd/server.crt" --key="/etc/kubernetes/pki/etcd/server.key" member remove <MEMBER_ID>'
    ```

1. Удалить-добавить ноду через Terraform
