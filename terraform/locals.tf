locals {
  vm_user           = "ubuntu"
  ansible_config    = "../ansible/ansible.cfg"
  ansible_playbook  = "../ansible/deploy_k8s_cluster.yml"
  ansible_inventory = "../ansible/inventories/k8s"
}
