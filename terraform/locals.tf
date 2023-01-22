locals {
  cluster_name      = "infra"
  vm_user           = "ubuntu"
  ansible_config    = "../ansible/ansible.cfg"
  ansible_playbook  = "../ansible/k8s_cluster_init.yml"
  ansible_inventory = "../ansible/inventories/k8s_${local.cluster_name}"

  k8s_common = {
    gw              = "192.168.13.1"
    ci_disk         = "ide2"
    boot_disk       = "scsi0"
    storage_move_to = "local-lvm"
    clone_k8s       = "${var.template_name}-k8s"
    clone_base      = "${var.template_name}-base"
  }

  k8s_controlplane = {
    k8s-controlplane-01 = {
      target_node      = "spmini"
      storage_clone_to = "spsrv-proxmox"
      vmid             = 8101
      ip               = "192.168.13.201"
      cores            = 2
      memory           = 4096
      disk             = "20G"
    },
    k8s-controlplane-02 = {
      target_node      = "sppve"
      storage_clone_to = "spsrv-proxmox"
      vmid             = 8102
      ip               = "192.168.13.202"
      cores            = 2
      memory           = 4096
      disk             = "20G"
    },
    k8s-controlplane-03 = {
      target_node      = "spsrv"
      storage_clone_to = "local-lvm"
      vmid             = 8103
      ip               = "192.168.13.203"
      cores            = 2
      memory           = 4096
      disk             = "20G"
    }
  }

  k8s_worker = {
    k8s-worker-01 = {
      target_node      = "spmini"
      storage_clone_to = "spsrv-proxmox"
      vmid             = 8111
      ip               = "192.168.13.211"
      ip_data          = "10.10.20.211"
      cores            = 6
      memory           = 16384
      disk             = "50G"
    },
    k8s-worker-02 = {
      target_node      = "sppve"
      storage_clone_to = "spsrv-proxmox"
      vmid             = 8112
      ip               = "192.168.13.212"
      ip_data          = "10.10.20.212"
      cores            = 6
      memory           = 16384
      disk             = "50G"
    },
    k8s-worker-03 = {
      target_node      = "spsrv"
      storage_clone_to = "local-lvm"
      vmid             = 8113
      ip               = "192.168.13.213"
      ip_data          = "10.10.20.213"
      cores            = 4
      memory           = 16384
      disk             = "50G"
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
