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
