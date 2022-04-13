variable "proxmox_url" {
  description = "Proxmox API URL, including the full path"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox API Username, including the realm"
  type        = string
  sensitive   = true
}

variable "proxmox_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
}

variable "ssh_pub_keys" {
  description = "SSH public keys to add to authorized keys file for the cloud-init user"
  type        = string
}

variable "template_name" {
  description = "The base VM from which to clone to create the new VM"
  type        = string
}
