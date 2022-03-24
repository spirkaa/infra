resource "proxmox_vm_qemu" "k8s_controlplane" {
  count       = 3
  target_node = var.pve_node
  name        = "k8s-controlplane-0${count.index + 1}"
  desc        = "Kubernetes control plane node"
  clone       = "${var.template_name}-k8s"
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
    size    = "15G"
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
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done"]

    connection {
      host        = self.default_ipv4_address
      user        = local.vm_user
      timeout     = "10s"
      private_key = file("~/.ssh/id_rsa")
    }
  }
}
