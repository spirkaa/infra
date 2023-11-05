terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://s3.home.devmem.ru"
    }
    region = "main"

    bucket = "terraform"
    key    = "infra/terraform.tfstate"

    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }
}
