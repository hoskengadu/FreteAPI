# ==========================================
# AWS Module Outputs
# ==========================================

# Network Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.network.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnet IDs"
  value       = module.network.database_subnet_ids
}

# Database Outputs
output "database_endpoint" {
  description = "Database endpoint"
  value       = module.rds.endpoint
}

output "database_port" {
  description = "Database port"
  value       = module.rds.port
}

output "database_name" {
  description = "Database name"
  value       = module.rds.database_name
}

output "database_username" {
  description = "Database master username"
  value       = module.rds.username
  sensitive   = true
}

output "database_arn" {
  description = "Database ARN"
  value       = module.rds.arn
}

# ECS Outputs
output "cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs.cluster_name
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = module.ecs.cluster_arn
}

output "service_name" {
  description = "ECS Service name"
  value       = module.ecs.service_name
}

output "service_arn" {
  description = "ECS Service ARN"
  value       = module.ecs.service_arn
}

output "load_balancer_dns" {
  description = "Application Load Balancer DNS name"
  value       = module.ecs.load_balancer_dns
}

output "load_balancer_arn" {
  description = "Application Load Balancer ARN"
  value       = module.ecs.load_balancer_arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecs.ecr_repository_url
}

output "api_url" {
  description = "API URL"
  value       = module.ecs.api_url
}

# Monitoring Outputs
output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.ecs.log_group_name
}

# Security Groups
output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = module.network.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "ECS Security Group ID"
  value       = module.network.ecs_security_group_id
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = module.network.rds_security_group_id
}