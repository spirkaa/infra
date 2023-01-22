include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../module"
}

inputs = {
  bucket = "signoz"
}
