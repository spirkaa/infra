variable "proxmox_url" {
  description = "URL to the Proxmox API, including the full path"
  type        = string
}

variable "proxmox_username" {
  description = "Username when authenticating to Proxmox, including the realm"
  type        = string
  sensitive   = true
}

variable "proxmox_token" {
  description = "Token for authenticating API calls"
  type        = string
  sensitive   = true
}

variable "ssh_key" {
  description = "Public SSH key"
  type        = string
}
