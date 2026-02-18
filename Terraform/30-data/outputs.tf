output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_sg_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_sg.id
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.mysql.identifier
}