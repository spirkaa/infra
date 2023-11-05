include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../minio-bucket"
}

inputs = {
  bucket = "signoz"
}
