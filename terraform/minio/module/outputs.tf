output "aws_access_key_id" {
  description = "S3 Access Key Id"
  value       = minio_iam_user.this.name
}

output "aws_secret_access_key" {
  description = "S3 Secret Access Key"
  value       = minio_iam_user.this.secret
  sensitive   = true
}
