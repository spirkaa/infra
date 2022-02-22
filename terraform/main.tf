terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 2.9.6"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure     = true
  pm_api_url          = var.proxmox_url
  pm_api_token_id     = var.proxmox_username
  pm_api_token_secret = var.proxmox_token
}

locals {
  vm_user           = "ubuntu"
  ansible_config    = "../ansible/ansible.cfg"
  ansible_playbook  = "../ansible/deploy_k8s_cluster.yml"
  ansible_inventory = "../ansible/inventories/k8s"
}

resource "proxmox_vm_qemu" "k8s_controlplane" {
  count       = 3
  target_node = var.pve_node
  name        = "k8s-controlplane-0${count.index + 1}"
  desc        = "Kubernetes control plane node"
  clone       = var.template_name
  vmid        = "810${count.index + 1}"

  cpu     = "kvm64"
  cores   = 2
  sockets = 1
  memory  = 4096

  os_type = "cloud-init"
  qemu_os = "l26"
  agent   = 1
  scsihw  = "virtio-scsi-pci"

  ssh_forward_ip = "192.168.13.20${count.index + 1}"
  ipconfig0      = "ip=192.168.13.20${count.index + 1}/24,gw=192.168.13.1"
  sshkeys        = <<EOF
  ${var.ssh_key}
EOF

  disk {
    slot    = 0
    type    = "scsi"
    storage = "local-lvm"
    size    = "10G"
    discard = "on"
    ssd     = 1
  }

  network {
    model  = "virtio"
    bridge = "vmbr1"
    tag    = 13
  }

  vga {
    memory = 0
    type   = "serial0"
  }

  serial {
    id   = 0
    type = "socket"
  }

  lifecycle {
    ignore_changes = [
      ciuser
    ]
  }

  provisioner "remote-exec" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]

    connection {
      host    = self.default_ipv4_address
      user    = local.vm_user
      timeout = "10s"
    }
  }
}

resource "proxmox_vm_qemu" "k8s_worker" {
  count       = 3
  target_node = var.pve_node
  name        = "k8s-worker-0${count.index + 1}"
  desc        = "Kubernetes worker node"
  clone       = var.template_name
  vmid        = "811${count.index + 1}"

  cpu     = "kvm64"
  cores   = 4
  sockets = 1
  memory  = 8192

  os_type = "cloud-init"
  qemu_os = "l26"
  agent   = 1
  scsihw  = "virtio-scsi-pci"

  ssh_forward_ip = "192.168.13.21${count.index + 1}"
  ipconfig0      = "ip=192.168.13.21${count.index + 1}/24,gw=192.168.13.1"
  sshkeys        = <<EOF
  ${var.ssh_key}
EOF

  disk {
    slot    = 0
    type    = "scsi"
    storage = "local-lvm"
    size    = "10G"
    discard = "on"
    ssd     = 1
  }

  network {
    model  = "virtio"
    bridge = "vmbr1"
    tag    = 13
  }

  vga {
    memory = 0
    type   = "serial0"
  }

  serial {
    id   = 0
    type = "socket"
  }

  lifecycle {
    ignore_changes = [
      ciuser
    ]
  }

  provisioner "remote-exec" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]

    connection {
      host    = self.default_ipv4_address
      user    = local.vm_user
      timeout = "10s"
    }
  }
}

resource "proxmox_vm_qemu" "k8s_lb" {
  count       = 2
  target_node = var.pve_node
  name        = "k8s-lb-0${count.index + 1}"
  desc        = "Load Balancer"
  clone       = var.template_name
  vmid        = "812${count.index + 1}"

  cpu     = "kvm64"
  cores   = 2
  sockets = 1
  memory  = 1024

  os_type = "cloud-init"
  qemu_os = "l26"
  agent   = 1
  scsihw  = "virtio-scsi-pci"

  ssh_forward_ip = "192.168.13.22${count.index + 1}"
  ipconfig0      = "ip=192.168.13.22${count.index + 1}/24,gw=192.168.13.1"
  sshkeys        = <<EOF
  ${var.ssh_key}
EOF

  disk {
    slot    = 0
    type    = "scsi"
    storage = "local-lvm"
    size    = "10G"
    discard = "on"
    ssd     = 1
  }

  network {
    model  = "virtio"
    bridge = "vmbr1"
    tag    = 13
  }

  vga {
    memory = 0
    type   = "serial0"
  }

  serial {
    id   = 0
    type = "socket"
  }

  lifecycle {
    ignore_changes = [
      ciuser
    ]
  }

  provisioner "remote-exec" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]

    connection {
      host    = self.default_ipv4_address
      user    = local.vm_user
      timeout = "10s"
    }
  }
}

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
