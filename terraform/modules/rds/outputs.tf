output "db_endpoint" {
  description = "Primary RDS endpoint"
  value       = aws_db_instance.primary.endpoint
}

output "read_replica_endpoint" {
  description = "Read replica endpoint"
  value       = aws_db_instance.read_replica.endpoint
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.primary.db_name
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}
