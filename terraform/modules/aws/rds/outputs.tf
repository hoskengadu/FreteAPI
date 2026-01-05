# ==========================================
# AWS RDS Outputs
# ==========================================

output "endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "port" {
  description = "Database port"
  value       = aws_db_instance.main.port
}

output "username" {
  description = "Database username"
  value       = aws_db_instance.main.username
}

output "instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}