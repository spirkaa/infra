resource "proxmox_vm_qemu" "k8s_worker" {
  for_each = local.k8s_worker

  name        = each.key
  target_node = each.value.target_node
  desc        = "Kubernetes worker"
  clone       = local.k8s_common.clone_k8s
  vmid        = each.value.vmid

  os_type = "cloud-init"
  qemu_os = "l26"
  agent   = 1
  scsihw  = "virtio-scsi-pci"
  onboot  = true

  ssh_forward_ip = each.value.ip
  ipconfig0      = "ip=${each.value.ip}/24,gw=${local.k8s_common.gw}"
  ipconfig1      = "ip=${each.value.ip_data}/24"
  sshkeys        = var.ssh_pub_keys

  memory = each.value.memory

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage    = each.value.storage_clone_to
          size       = each.value.disk
          discard    = true
          emulatessd = true
          replicate  = true
        }
      }
      scsi1 {
        disk {
          storage    = "local-lvm"
          size       = "200G"
          discard    = true
          emulatessd = true
          replicate  = true
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1"
    tag    = 13
  }

  network {
    id     = 1
    model  = "virtio"
    bridge = "vmbr1"
    tag    = 20
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
      clone,
      pool,
      ciuser,
      disks[0].scsi[0].scsi0[0].disk[0].storage,
    ]
  }

  provisioner "remote-exec" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done"]

    connection {
      host        = self.default_ipv4_address
      user        = local.vm_user
      timeout     = "120s"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  # Move disks from shared to local storage
  provisioner "local-exec" {
    command = <<EOT
      for disk in ${local.k8s_common.ci_disk} ${local.k8s_common.boot_disk}; do
        curl --silent --insecure \
          ${var.proxmox_url}/nodes/${each.value.target_node}/qemu/${each.value.vmid}/move_disk \
          --header "Authorization: PVEAPIToken=${var.proxmox_username}=${var.proxmox_token}" \
          --data-urlencode disk="$disk" \
          --data-urlencode storage="${local.k8s_common.storage_move_to}" \
          --data-urlencode delete=1
      done
    EOT
  }
}
