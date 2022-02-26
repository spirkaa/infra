resource "local_file" "ansible_inventory_file" {
  depends_on = [
    proxmox_vm_qemu.k8s_controlplane,
    proxmox_vm_qemu.k8s_worker,
    proxmox_vm_qemu.k8s_lb
  ]

  content = templatefile("templates/ansible-inventory.tpl", {
    k8s_controlplane = zipmap(
      tolist(proxmox_vm_qemu.k8s_controlplane.*.name),
      tolist(proxmox_vm_qemu.k8s_controlplane.*.ssh_forward_ip)
    )
    k8s_workers = zipmap(
      tolist(proxmox_vm_qemu.k8s_worker.*.name),
      tolist(proxmox_vm_qemu.k8s_worker.*.ssh_forward_ip)
    )
    k8s_lb = zipmap(
      tolist(proxmox_vm_qemu.k8s_lb.*.name),
      tolist(proxmox_vm_qemu.k8s_lb.*.ssh_forward_ip)
    )
    ansible_user = local.vm_user
  })
  filename = local.ansible_inventory
}

resource "null_resource" "ansible" {
  depends_on = [local_file.ansible_inventory_file]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "ansible-playbook ${local.ansible_playbook}"
    working_dir = "../ansible"
    environment = {
      ANSIBLE_INVENTORY   = local.ansible_inventory
      ANSIBLE_CONFIG      = local.ansible_config
      ANSIBLE_FORCE_COLOR = "True"
      ANSIBLE_VERBOSITY   = "0"
    }
  }
}
