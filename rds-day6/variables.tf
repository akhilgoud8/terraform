variable "identifier" {
  description = "Unique identifier for the RDS instance (lowercase, no underscores)"
  type        = string
}

variable "engine" {
  description = "Database engine (e.g. mysql, postgres, mariadb)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version. Leave null to let AWS pick the default for the engine."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "RDS instance class (e.g. db.t3.micro, db.t3.medium)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling in GB. Set to 0 to disable autoscaling."
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type: gp2, gp3, io1"
  type        = string
  default     = "gp3"
}

variable "db_name" {
  description = "Name of the default database created in the instance"
  type        = string
}

variable "username" {
  description = "Master username for the database"
  type        = string
  default     = "app_admin"
}

variable "password" {
  description = "Master password. If left empty, a random password is generated automatically and stored only in Terraform state / outputs (marked sensitive)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "port" {
  description = "Port the database listens on. Leave null to use the engine default."
  type        = number
  default     = null
}

variable "vpc_id" {
  description = "VPC ID the RDS instance and its security group will live in"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs (should be private subnets) for the DB subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database on the DB port"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to the database (e.g. an app tier SG)"
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Whether to deploy a Multi-AZ standby replica"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the RDS instance gets a public IP. Should be false in almost all cases."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (UTC), e.g. '03:00-04:00'"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window (UTC), e.g. 'sun:04:30-sun:05:30'"
  type        = string
  default     = "sun:04:30-sun:05:30"
}

variable "skip_final_snapshot" {
  description = "If true, no final snapshot is taken when the instance is destroyed (fine for dev, dangerous for prod)"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "If true, prevents the instance from being deleted via Terraform or the console until disabled"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Whether to encrypt storage at rest"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "If true, apply changes immediately instead of during the next maintenance window"
  type        = bool
  default     = false
}

variable "parameters" {
  description = "Map of DB parameter group parameters to set, e.g. { max_connections = \"100\" }"
  type        = map(string)
  default     = {}
}

variable "parameter_group_family" {
  description = "DB parameter group family (e.g. 'postgres15', 'mysql8.0'). Required only if var.parameters is non-empty — AWS parameter group families don't follow one consistent naming pattern across engines, so this must be supplied explicitly rather than guessed."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}
