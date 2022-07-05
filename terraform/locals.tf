locals {
  cluster_name      = "infra"
  vm_user           = "ubuntu"
  ansible_config    = "../ansible/ansible.cfg"
  ansible_playbook  = "../ansible/k8s_cluster_init.yml"
  ansible_inventory = "../ansible/inventories/k8s_${local.cluster_name}"

  k8s_common = {
    gw              = "192.168.13.1"
    bus_id          = "scsi0"
    storage_move_to = "local-lvm"
    clone_k8s       = "${var.template_name}-k8s"
    clone_base      = "${var.template_name}-base"
  }

  k8s_controlplane = {
    k8s-controlplane-04 = {
      target_node      = "spmini"
      storage_clone_to = "spsrv-proxmox"
      vmid             = 8104
      ip               = "192.168.13.204"
      cores            = 2
      memory           = 4096
      disk             = "20G"
    },
    k8s-controlplane-05 = {
      target_node      = "sppve"
      storage_clone_to = "spsrv-proxmox"
      vmid             = 8105
      ip               = "192.168.13.205"
      cores            = 2
      memory           = 4096
      disk             = "20G"
    },
    k8s-controlplane-06 = {
      target_node      = "spsrv"
      storage_clone_to = "local-lvm"
      vmid             = 8106
      ip               = "192.168.13.206"
      cores            = 2
      memory           = 4096
      disk             = "20G"
    }
  }

  k8s_worker = {
    k8s-worker-04 = {
      target_node      = "spmini"
      storage_clone_to = "spsrv-proxmox"
      vmid             = 8114
      ip               = "192.168.13.214"
      ip_data          = "10.10.20.214"
      cores            = 6
      memory           = 16384
      disk             = "40G"
    },
    k8s-worker-05 = {
      target_node      = "sppve"
      storage_clone_to = "spsrv-proxmox"
      vmid             = 8115
      ip               = "192.168.13.215"
      ip_data          = "10.10.20.215"
      cores            = 6
      memory           = 16384
      disk             = "40G"
    },
    k8s-worker-06 = {
      target_node      = "spsrv"
      storage_clone_to = "local-lvm"
      vmid             = 8116
      ip               = "192.168.13.216"
      ip_data          = "10.10.20.216"
      cores            = 4
      memory           = 16384
      disk             = "40G"
    }
  }

  k8s_lb = {
    k8s-lb-01 = {
      target_node      = "spsrv"
      storage_clone_to = "local-lvm"
      vmid             = 8121
      ip               = "192.168.13.221"
      cores            = 2
      memory           = 1024
      disk             = "10G"
    },
    k8s-lb-02 = {
      target_node      = "spmini"
      storage_clone_to = "spsrv-proxmox"
      vmid             = 8122
      ip               = "192.168.13.222"
      cores            = 2
      memory           = 1024
      disk             = "10G"
    }
  }
}
