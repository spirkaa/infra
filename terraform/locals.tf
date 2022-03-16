locals {
  vm_user           = "ubuntu"
  ansible_config    = "../ansible/ansible.cfg"
  ansible_playbook  = "../ansible/k8s_cluster_init.yml"
  ansible_inventory = "../ansible/inventories/k8s"
}
