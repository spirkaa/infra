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

### Observability (логи, метрики, трейсы)

* [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts)
  * [Prometheus](https://github.com/prometheus/prometheus)
  * [Alertmanager](https://github.com/prometheus/alertmanager) + [alertmanager-notifier](https://github.com/ix-ai/alertmanager-notifier)
  * [Grafana](https://github.com/grafana/grafana)

* [loki-stack](https://github.com/grafana/helm-charts/tree/main/charts/loki-stack)
  * [Loki](https://github.com/grafana/loki)
  * [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/)

### GitOps

* [ArgoCD](https://github.com/argoproj/argo-cd) + [argocd-lovely-plugin](https://github.com/crumbhole/argocd-lovely-plugin) + [argocd-vault-plugin](https://github.com/argoproj-labs/argocd-vault-plugin)
* [Renovate](https://github.com/renovatebot/renovate)

### Secrets

* [Vault](https://github.com/hashicorp/vault) + [vault-bootstrap](https://github.com/spirkaa/vault-bootstrap)
* [external-secrets](https://github.com/external-secrets/external-secrets/)

### Auth

* [authentik](https://github.com/goauthentik/authentik)
* [teleport](https://github.com/gravitational/teleport)

### Утилиты

* [descheduler](https://github.com/kubernetes-sigs/descheduler)
* [Kured](https://github.com/weaveworks/kured)

## Запуск

### Требования

* Сервер Proxmox
* Клиент Linux с установленными git и docker для запуска контейнера с утилитами

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
1. [Packer](https://www.packer.io/) клонирует шаблон из п.1, запускает, настраивает с помощью Ansible, преобразует в шаблон.

Разворачивание ВМ из шаблона выполняется с помощью [Terraform](https://www.terraform.io/).

## Выключение/перезагрузка ноды

1. Снять нагрузку

    `kubectl drain k8s-worker-01 --ignore-daemonsets --delete-emptydir-data --pod-selector='app!=csi-attacher,app!=csi-provisioner'`

1. Настроить заглушку уведомлений в Alertmanager

1. После включения разрешить нагрузку

    `kubectl uncordon k8s-worker-01`

## Увеличение тома Longhorn при использовании операторов Kubernetes

### Проблемы

* Longhorn не поддерживает изменение размера томов на лету, поэтому том должен быть отключен (Detached), а следовательно под, использующий том, должен быть удален. А перед этим нужно удалить StatefulSet или Deployment.
* Операторы Kubernetes постоянно отслеживают и исправляют состояние, например, создают удаленные вручную StatefulSet или Deployment.
* StatefulSet не поддерживает изменение volumeClaimTemplates.

### Решение для StatefulSet на примере kube-prometheus-stack (Prometheus Operator) и ArgoCD

1. Отключить или настроить все операторы, выполняющие согласование (reconciliation) объектов Kubernetes, с которыми связан целевой том:
    1. Отключить автоматическую синхронизацию и исправление приложения в [ArgoCD](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/): в коде удалить блок `Application.spec.syncPolicy` и отправить в репозиторий, дождаться синхронизации
    1. Уменьшить реплики Prometheus Operator до 0

        `kubectl -n observability scale deployment kps-operator --replicas 0`

1. Удалить StatefulSet, но оставить зависимые объекты (Pod, PersistentVolumeClaim)

    `kubectl -n observability delete statefulsets.apps prometheus-kps-prometheus --cascade=orphan`

1. Удалить Pod, тем самым переведя том Longhorn в состояние Detached

    `kubectl -n observability delete pod prometheus-kps-prometheus-0`

1. Отредактировать PersistentVolumeClaim, указав новый размер в `spec.resources.requests.storage`

    `kubectl -n observability edit pvc prometheus-kps-prometheus-db-prometheus-kps-prometheus-0`

1. Дождаться применения изменений драйвером Longhorn

    `kubectl -n observability describe pvc prometheus-kps-prometheus-db-prometheus-kps-prometheus-0`

    ```log
      Events:
        Type     Reason                  Age   From                                 Message
        ----     ------                  ----  ----                                 -------
        Warning  ExternalExpanding       34s   volume_expand                        Ignoring the PVC: didn't find a plugin capable of expanding the volume; waiting for an external controller to process this PVC.
        Normal   Resizing                34s   external-resizer driver.longhorn.io  External resizer is resizing volume pvc-a4de8e0e-c664-4f60-be90-ddb0207eae7f
        Normal   VolumeResizeSuccessful  22s   external-resizer driver.longhorn.io  Resize volume succeeded
    ```

1. Задать в коде новый размер PersistentVolumeClaim в `prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage`

1. Вернуть в коде `Application.spec.syncPolicy`, отправить в репозиторий, запустить синхронизацию в ArgoCD

1. Вернуть исходное количество реплик оператора из п.1, в результате чего оператор пересоздаст удаленный ранее StatefulSet

    `kubectl -n observability scale deployment kps-operator --replicas 1`

### Решение для Deployment

1. Удалить в коде `Application.spec.syncPolicy`, отправить в репозиторий, дождаться синхронизации ArgoCD
1. Удалить Deployment
1. Задать в коде новый размер `PersistentVolumeClaim`, отправить в репозиторий, запустить синхронизацию только ресурса PersistentVolumeClaim в ArgoCD, а не всего приложения
1. Дождаться применения изменений драйвером Longhorn
1. Вернуть в коде `Application.spec.syncPolicy`, отправить в репозиторий, запустить синхронизацию в ArgoCD

### Ссылки по теме

* <https://longhorn.io/docs/1.2.4/volumes-and-nodes/expansion/>
* <https://itnext.io/resizing-statefulset-persistent-volumes-with-zero-downtime-916ebc65b1d4>
