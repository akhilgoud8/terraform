variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance and EC2 client will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group (must span at least 2 AZs)"
  type        = list(string)
}

variable "client_subnet_id" {
  description = "Subnet ID for the EC2 client instance (should be one of subnet_ids, public if you need SSH from your IP)"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Your public IP in CIDR form, e.g. 203.0.113.10/32"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
  default     = "rds-key"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for the RDS instance (pass via TF_VAR_db_password or a tfvars file excluded from VCS)"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name created on the RDS instance"
  type        = string
  default     = "dev"
}
