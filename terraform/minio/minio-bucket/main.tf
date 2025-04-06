terraform {
  required_version = "~> 1.4"
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "~> 3.3"
    }
  }
}
