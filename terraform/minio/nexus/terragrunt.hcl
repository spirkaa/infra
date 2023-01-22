include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../module"
}

locals {
  bucket = "nexus"
}

inputs = {
  bucket            = local.bucket
  bucket_iam_policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:*"
          ],
          "Resource": [
            "arn:aws:s3:::${local.bucket}/*",
            "arn:aws:s3:::${local.bucket}"
          ]
        }
      ]
    }
  EOT
}
