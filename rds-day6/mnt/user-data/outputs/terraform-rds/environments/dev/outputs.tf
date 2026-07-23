output "db_instance_endpoint" {
  description = "RDS connection endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_id" {
  description = "RDS instance identifier"
  value       = module.rds.db_instance_id
}

output "db_security_group_id" {
  description = "Security group protecting the RDS instance"
  value       = module.rds.security_group_id
}

output "resolved_vpc_id" {
  description = "The VPC ID actually used (from data source lookup or override)"
  value       = local.vpc_id
}

output "resolved_subnet_ids" {
  description = "The subnet IDs actually used (from data source lookup or override)"
  value       = local.subnet_ids
}

output "master_password" {
  description = "Master DB password (sourced from TF_VAR_db_password)"
  value       = module.rds.master_password
  sensitive   = true
}
