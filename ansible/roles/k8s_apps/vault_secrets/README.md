# Роль Ansible: Vault Secrets

Роль Ansible для создания/обновления секретов в [Hashicorp Vault](https://github.com/hashicorp/vault), развернутом в кластере Kubernetes.

## Переменные

См. в [defaults/main.yml](defaults/main.yml).

**Нельзя использовать один и тот же `path` с разными значениями `kv`!**

Так как для работы с секретами используется cli команда [`kv put`](https://www.vaultproject.io/docs/commands/kv/put), секреты в K/V v2 всегда заменяются на новую версию целиком. Поэтому каждый элемент списка в переменной `vault_secrets` должен включать все пары key=value в `kv`, которые будут записаны в хранилище по пути `path`.

## Зависимости

* kubeconfig
* токен vault
