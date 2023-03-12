terraform {
  required_version = "~> 1.4"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9.11"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure     = true
  pm_api_url          = var.proxmox_url
  pm_api_token_id     = var.proxmox_username
  pm_api_token_secret = var.proxmox_token
  pm_parallel         = 2
}
