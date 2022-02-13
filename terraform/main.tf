terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.5"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure     = true
  pm_api_url          = var.proxmox_url
  pm_api_token_id     = var.proxmox_username
  pm_api_token_secret = var.proxmox_token

  # pm_log_enable = true
  # pm_log_file   = "terraform-plugin-proxmox.log"
  # pm_debug      = true
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = ""
  # }
}

resource "proxmox_vm_qemu" "tf-test" {
  count       = 1
  target_node = "spmaxi"
  name        = "tf-test-0${count.index}"
  desc        = "Created with Terraform"
  clone       = "tpl-ubuntu-2004-min"
  vmid        = "810${count.index}"

  cpu     = "kvm64"
  cores   = 2
  sockets = 1
  memory  = 4096

  os_type = "cloud-init"
  qemu_os = "l26"
  agent   = 1
  scsihw  = "virtio-scsi-pci"

  ipconfig0 = "ip=192.168.13.21${count.index}/24,gw=192.168.13.1"
  sshkeys   = <<EOF
  ${var.ssh_key}
EOF

  disk {
    slot    = 0
    type    = "scsi"
    storage = "local-lvm"
    size    = "20G"
    discard = "on"
    ssd     = 1
    backup  = 1
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

  lifecycle {
    ignore_changes = [
      ciuser,
    ]
  }
}
