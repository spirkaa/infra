remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    endpoint                    = "https://s3.home.devmem.ru"
    region                      = "main"
    bucket                      = "terraform"
    key                         = "minio/${path_relative_to_include()}/terraform.tfstate"
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    force_path_style            = true
    skip_bucket_versioning      = true
    disable_bucket_update       = true
  }
}
