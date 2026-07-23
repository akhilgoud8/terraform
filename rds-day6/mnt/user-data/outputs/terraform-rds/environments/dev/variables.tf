variable "project_name" {
  description = "Project name used for naming/tagging"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# --- Values with defaults here, but expected to be overridden by terraform.tfvars ---

variable "db_instance_class" {
  description = "RDS instance class. SOURCE: defaults here, overridden per-environment in terraform.tfvars."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB. SOURCE: terraform.tfvars."
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ. SOURCE: terraform.tfvars (true in prod, false in dev)."
  type        = bool
  default     = false
}

# --- Value intentionally left with NO default: must come from an environment
#     variable (TF_VAR_db_password) or -var on the CLI, never committed to git ---

variable "db_password" {
  description = "Master DB password. SOURCE: environment variable TF_VAR_db_password (never set a default or put this in tfvars/version control)."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 12
    error_message = "db_password must be at least 12 characters long."
  }
}

# --- Values looked up dynamically instead of hardcoded — see data.tf.
#     Exposed here only so callers *can* override and skip the data lookup
#     (e.g. in CI, or the test suite) if they already know the IDs. ---

variable "vpc_id_override" {
  description = "Optional: skip the default-VPC data lookup and use this VPC ID instead. SOURCE: CLI -var, used mainly by tests."
  type        = string
  default     = null
}

variable "subnet_ids_override" {
  description = "Optional: skip the subnet data lookup and use these subnet IDs instead. SOURCE: CLI -var, used mainly by tests."
  type        = list(string)
  default     = null
}
