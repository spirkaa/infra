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

source "proxmox-clone" "template" {
  insecure_skip_tls_verify = true
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  node                     = var.node
  clone_vm                 = var.clone_vm

  template_description = "Built with Packer on ${timestamp()}"

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
  source "proxmox-clone.template" {
    name          = "base"
    template_name = "${var.template_name}-${source.name}"
    vm_id         = var.vm_id_base
  }

  source "proxmox-clone.template" {
    name          = "k8s"
    template_name = "${var.template_name}-${source.name}"
    vm_id         = var.vm_id_k8s
  }

  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done"]
  }

  provisioner "ansible" {
    user             = "ubuntu"
    playbook_file    = "../ansible/packer_provisioner.yml"
    extra_arguments  = ["-t ${source.name}"]
    ansible_env_vars = ["ANSIBLE_CONFIG=../ansible/ansible.cfg"]
  }

  provisioner "shell" {
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    scripts = [
      "scripts/packer-virt-sysprep/sysprep-op-cloud-init.sh",
      "scripts/packer-virt-sysprep/sysprep-op-logfiles.sh",
      "scripts/packer-virt-sysprep/sysprep-op-machine-id.sh",
      "scripts/packer-virt-sysprep/sysprep-op-package-manager-cache.sh",
      "scripts/packer-virt-sysprep/sysprep-op-package-manager-db.sh",
      "scripts/packer-virt-sysprep/sysprep-op-tmp-files.sh"
    ]
  }
}
