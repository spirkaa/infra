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

variable "node" {
  description = "Which node in the Proxmox cluster to start the virtual machine on during creation"
  type        = string
  default     = env("TF_VAR_pve_node")
}

variable "vm_id" {
  description = "The ID used to reference the virtual machine"
  type        = number
  default     = env("STAGE1_VM_ID")
}

variable "clone_vm" {
  description = "The name of the VM Packer should clone and build from"
  type        = string
  default     = env("STAGE0_VM_NAME")
}

variable "template_name" {
  description = "Name of the template"
  type        = string
  default     = env("TF_VAR_template_name")
}
