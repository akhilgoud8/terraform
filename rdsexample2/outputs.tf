output "rds_endpoint" {
  description = "RDS connection endpoint (host:port)"
  value       = aws_db_instance.primary.endpoint
}

output "rds_address" {
  description = "RDS host address (no port)"
  value       = aws_db_instance.primary.address
}

output "client_public_ip" {
  description = "Public IP of the EC2 client instance"
  value       = aws_instance.client.public_ip
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets used by the RDS subnet group"
  value       = aws_subnet.private[*].id
}
