variable "proxmox_url" {
  description = "Proxmox API URL, including the full path"
  type        = string
  default     = env("TF_VAR_proxmox_url")
}

variable "proxmox_username" {
  description = "Proxmox API Username, including the realm"
  type        = string
  sensitive   = true
  default     = env("TF_VAR_proxmox_username")
}

variable "proxmox_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
  default     = env("TF_VAR_proxmox_token")
}

variable "proxmox_node" {
  description = "Which node in the Proxmox cluster to start the VM on during creation"
  type        = string
  default     = env("PROXMOX_NODE")
}

variable "vm_id_base" {
  description = "The ID used to reference the VM for base template"
  type        = number
  default     = env("STAGE1_VM_ID_BASE")
}

variable "vm_id_k8s" {
  description = "The ID used to reference the VM for k8s template"
  type        = number
  default     = env("STAGE1_VM_ID_K8S")
}

variable "clone_vm" {
  description = "The name of the VM Packer should clone and build from"
  type        = string
  default     = env("STAGE0_VM_NAME")
}

variable "template_name" {
  description = "Name of the resulting VM template"
  type        = string
  default     = env("TF_VAR_template_name")
}
