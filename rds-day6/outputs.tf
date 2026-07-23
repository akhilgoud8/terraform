output "db_instance_id" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_instance_endpoint" {
  description = "Connection endpoint in the form address:port"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "Hostname of the RDS instance (no port)"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "Port the database is listening on"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Name of the default database"
  value       = aws_db_instance.this.db_name
}

output "master_username" {
  description = "Master username"
  value       = aws_db_instance.this.username
}

output "master_password" {
  description = "Master password (either the one supplied, or the auto-generated one). Sensitive — pull with `terraform output -raw master_password`."
  value       = local.password
  sensitive   = true
}

output "security_group_id" {
  description = "ID of the security group attached to the RDS instance"
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.this.name
}

output "parameter_group_name" {
  description = "Name of the custom parameter group, if one was created"
  value       = local.needs_parameter_group ? aws_db_parameter_group.this[0].name : null
}
