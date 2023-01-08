terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 1.10.0"
    }
  }
}

resource "minio_s3_bucket" "this" {
  bucket        = var.bucket
  acl           = var.bucket_acl
  force_destroy = var.bucket_force_destroy
}

resource "minio_iam_user" "this" {
  name          = var.bucket
  update_secret = var.user_update_secret
}

resource "minio_iam_group" "this" {
  name = var.bucket
}

resource "minio_iam_policy" "this" {
  name   = var.bucket
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "${minio_s3_bucket.this.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${minio_s3_bucket.this.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "minio_iam_group_user_attachment" "this" {
  group_name = minio_iam_group.this.name
  user_name  = minio_iam_user.this.name
}

resource "minio_iam_group_policy_attachment" "this" {
  group_name  = minio_iam_group.this.name
  policy_name = minio_iam_policy.this.name
}

resource "minio_ilm_policy" "this" {
  count = var.bucket_ilm_policy == null ? 0 : 1

  bucket = minio_s3_bucket.this.bucket

  dynamic "rule" {
    for_each = { for policy in var.bucket_ilm_policy : policy.id => policy }
    content {
      id         = rule.value.id
      expiration = rule.value.expiration
      filter     = rule.value.filter
    }
  }
}
