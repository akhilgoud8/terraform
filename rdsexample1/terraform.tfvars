# Copy this to terraform.tfvars and fill in real values.
# NEVER commit terraform.tfvars (with real secrets) to version control.
# Prefer: export TF_VAR_db_password="..." instead of writing it to a file.

aws_region       = "us-east-1"
vpc_id           = "vpc-xxxxxxxx"
subnet_ids       = ["subnet-aaaaaaa", "subnet-bbbbbbb"]  # at least 2 AZs for the DB subnet group
client_subnet_id = "subnet-aaaaaaa"                       # public subnet if you SSH in directly
allowed_ssh_cidr = "203.0.113.10/32"                       # your public IP
key_name         = "rds-key"
db_username      = "admin"
db_name          = "dev"
# db_password    = set via TF_VAR_db_password env var, not here
