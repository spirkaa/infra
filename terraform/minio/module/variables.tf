variable "bucket" {
  description = "Bucket name"
  type        = string
}

variable "bucket_acl" {
  description = "Bucket Access Policy"
  type        = string
  default     = "private"
}

variable "bucket_force_destroy" {
  description = "Allow destroy non-empty bucket"
  type        = bool
  default     = false
}

variable "bucket_iam_policy" {
  description = "Bucket IAM Policy"
  type        = string
  default     = ""
}

variable "bucket_ilm_policy" {
  description = "Bucket lifecycle management policy list"
  type = list(object({
    id         = string
    expiration = string
    filter     = optional(string, null)
  }))
  default = null
}

variable "user_update_secret" {
  description = "Rotate user secret"
  type        = bool
  default     = null
}
