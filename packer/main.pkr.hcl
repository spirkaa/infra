packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = "1.0.4"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "1.0.1"
    }
  }
}

source "proxmox-clone" "ubuntu-2004" {
  insecure_skip_tls_verify = true
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  node                     = var.node
  clone_vm                 = var.clone_vm

  template_name        = var.template_name
  template_description = "Built with Packer on ${timestamp()}"
  vm_id                = var.vm_id

  cpu_type = "kvm64"
  cores    = 2
  sockets  = 1
  memory   = 2048

  os              = "l26"
  scsi_controller = "virtio-scsi-pci"

  ssh_username = "ubuntu"

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr1"
    vlan_tag = 13
  }

  vga {
    memory = 0
    type   = "serial0"
  }
}

build {
  sources = ["source.proxmox-clone.ubuntu-2004"]

  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]
  }

  provisioner "ansible" {
    user             = "ubuntu"
    playbook_file    = "../ansible/packer_provisioner.yml"
    ansible_env_vars = ["ANSIBLE_CONFIG=../ansible/ansible.cfg"]
    # extra_arguments = [ "-v" ]
  }

  provisioner "shell" {
    inline = ["sudo cloud-init clean"]
  }
}
