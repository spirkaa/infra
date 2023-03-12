resource "local_file" "ansible_inventory_file" {
  depends_on = [
    proxmox_vm_qemu.k8s_controlplane,
    proxmox_vm_qemu.k8s_worker,
    proxmox_vm_qemu.k8s_lb
  ]

  content = templatefile("templates/ansible-inventory.tftpl", {
    k8s_controlplane = zipmap(
      values(proxmox_vm_qemu.k8s_controlplane)[*].name,
      values(proxmox_vm_qemu.k8s_controlplane)[*].ssh_forward_ip
    )
    k8s_workers = zipmap(
      values(proxmox_vm_qemu.k8s_worker)[*].name,
      values(proxmox_vm_qemu.k8s_worker)[*].ssh_forward_ip
    )
    k8s_lb = zipmap(
      values(proxmox_vm_qemu.k8s_lb)[*].name,
      values(proxmox_vm_qemu.k8s_lb)[*].ssh_forward_ip
    )
    cluster_name = local.cluster_name
    ansible_user = local.vm_user
  })
  filename = local.ansible_inventory
}

resource "terraform_data" "ansible" {
  depends_on = [
    local_file.ansible_inventory_file
  ]

  triggers_replace = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "ansible-playbook ${local.ansible_playbook}"
    working_dir = "../ansible"
    environment = {
      ANSIBLE_INVENTORY = local.ansible_inventory
      ANSIBLE_CONFIG    = local.ansible_config
    }
  }
}
