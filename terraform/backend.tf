terraform {
  backend "s3" {
    endpoint = "https://s3.devmem.ru"
    region   = "main"

    bucket = "terraform"
    key    = "infra/terraform.tfstate"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
