# ==========================================
# Outputs - Multi-Cloud
# ==========================================

# Common outputs
output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "environment" {
  description = "Environment"
  value       = var.environment
}

output "cloud_provider" {
  description = "Cloud provider(s) used"
  value       = var.cloud_provider
}

output "api_image" {
  description = "API Docker image"
  value       = module.common.api_image
}

# AWS Outputs
output "aws_endpoint" {
  description = "AWS API endpoint URL"
  value       = var.cloud_provider == "aws" || var.cloud_provider == "multi" ? module.aws[0].api_endpoint : null
}

output "aws_database_endpoint" {
  description = "AWS RDS endpoint"
  value       = var.cloud_provider == "aws" || var.cloud_provider == "multi" ? module.aws[0].database_endpoint : null
}

output "aws_load_balancer_dns" {
  description = "AWS Load Balancer DNS name"
  value       = var.cloud_provider == "aws" || var.cloud_provider == "multi" ? module.aws[0].load_balancer_dns : null
}

# Azure Outputs
output "azure_endpoint" {
  description = "Azure API endpoint URL"
  value       = var.cloud_provider == "azure" || var.cloud_provider == "multi" ? module.azure[0].api_endpoint : null
}

output "azure_database_endpoint" {
  description = "Azure PostgreSQL endpoint"
  value       = var.cloud_provider == "azure" || var.cloud_provider == "multi" ? module.azure[0].database_endpoint : null
}

output "azure_load_balancer_ip" {
  description = "Azure Load Balancer public IP"
  value       = var.cloud_provider == "azure" || var.cloud_provider == "multi" ? module.azure[0].load_balancer_ip : null
}

# GCP Outputs
output "gcp_endpoint" {
  description = "GCP API endpoint URL"
  value       = var.cloud_provider == "gcp" || var.cloud_provider == "multi" ? module.gcp[0].api_endpoint : null
}

output "gcp_database_endpoint" {
  description = "GCP Cloud SQL endpoint"
  value       = var.cloud_provider == "gcp" || var.cloud_provider == "multi" ? module.gcp[0].database_endpoint : null
}

output "gcp_load_balancer_ip" {
  description = "GCP Load Balancer IP"
  value       = var.cloud_provider == "gcp" || var.cloud_provider == "multi" ? module.gcp[0].load_balancer_ip : null
}

# Database credentials (sensitive)
output "database_username" {
  description = "Database username"
  value       = "freteapi"
  sensitive   = false
}

output "database_password" {
  description = "Database password"
  value       = random_password.db_password.result
  sensitive   = true
}

# Migration status
output "migrations_executed" {
  description = "Whether migrations were executed in this run"
  value       = var.run_migrations
}