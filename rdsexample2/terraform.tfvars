# Copy this to terraform.tfvars and fill in real values.
# NEVER commit terraform.tfvars (with real secrets) to version control.
# Prefer: export TF_VAR_db_password="..." instead of writing it to a file.

aws_region       = "us-east-1"
vpc_cidr         = "10.0.0.0/16" # VPC + 2 public + 2 private subnets are created automatically from this
allowed_ssh_cidr = "0.0.0.0/0"   # your public IP
key_name         = "rds-key"
db_username      = "admin"
db_name          = "dev"
db_password      = "Cloud123"
