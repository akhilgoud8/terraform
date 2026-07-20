variable "app_bucket_name" {
  description = "Name of the S3 bucket that developer/readonly/EC2 policies grant access to"
  type        = string
  default     = "my-companys3bucket"
}

variable "trusted_account_arn" {
  description = "ARN of the external/trusted AWS account allowed to assume the cross-account role"
  type        = string
  default     = "arn:aws:iam::837563944836:user/cloud_user"
}


variable "force_destroy" {
  description = "Allow Terraform to delete IAM users even if they have attached resources (access keys, MFA devices, etc.)"
  type        = bool
  default     = true
}

variable "users" {
  description = "Map of IAM users to create. Keys are usernames."
  type = map(object({
    groups               = list(string)          # must match keys used in local.group_name_map
    create_login_profile = optional(bool, false) # create a console password
    tags                 = optional(map(string), {})
  }))

  default = {
    alice = { groups = ["admins"] }
    bob   = { groups = ["developers"] }
    carol = { groups = ["readonly"] }
  }
}
