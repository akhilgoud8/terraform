locals {
  # SOURCE: computed locally from other variables (not passed in directly by any file)
  identifier = "${var.project_name}-${var.environment}-db"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "rds" {
  source = "../../modules/rds"

  # SOURCE: locals computed above
  identifier = local.identifier
  tags       = local.common_tags

  # SOURCE: hardcoded directly in this file (rarely changes, tied to app code)
  engine         = "postgres"
  engine_version = "15.4"
  db_name        = "appdb"
  username       = "app_admin"

  # SOURCE: variables.tf defaults, overridden per-environment via terraform.tfvars
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  multi_az          = var.db_multi_az

  # SOURCE: environment variable TF_VAR_db_password (never defaulted, never committed)
  password = var.db_password

  # SOURCE: data source lookups (see data.tf), with an override escape hatch
  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids

  allowed_cidr_blocks = ["10.0.0.0/16"]

  skip_final_snapshot = var.environment != "prod"
  deletion_protection = var.environment == "prod"
}
