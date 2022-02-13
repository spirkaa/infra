packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = "1.0.4"
    }
  }
}

variable "proxmox_url" {
  description = "URL to the Proxmox API, including the full path"
  type        = string
  default     = env("TF_VAR_proxmox_url")
}

variable "proxmox_username" {
  description = "Username when authenticating to Proxmox, including the realm"
  type        = string
  sensitive   = true
  default     = env("TF_VAR_proxmox_username")
}

variable "proxmox_token" {
  description = "Token for authenticating API calls"
  type        = string
  sensitive   = true
  default     = env("TF_VAR_proxmox_token")
}

source "proxmox-clone" "ubuntu-2004-min" {
  insecure_skip_tls_verify = true
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  node                     = "spmaxi"
  clone_vm                 = "ubuntu-2004-min"

  template_name        = "tpl-ubuntu-2004-min"
  template_description = "Created with Packer"
  vm_id                = "9000"

  os              = "l26"
  cores           = "2"
  memory          = "2048"
  cpu_type        = "kvm64"
  scsi_controller = "virtio-scsi-pci"

  ssh_username = "ubuntu"

  vga {
    type = "serial0"
  }

  network_adapters {
    bridge   = "vmbr1"
    model    = "virtio"
    vlan_tag = "13"
  }
}

build {
  sources = ["source.proxmox-clone.ubuntu-2004-min"]

  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]
  }

  provisioner "shell" {
    inline = ["sudo cloud-init clean"]
  }
}
