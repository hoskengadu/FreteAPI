# ==========================================
# Development Environment Outputs
# ==========================================

# AWS Outputs
output "aws_api_url" {
  description = "AWS API URL"
  value       = var.deploy_to_aws ? module.aws[0].load_balancer_dns : null
}

output "aws_database_endpoint" {
  description = "AWS Database endpoint"
  value       = var.deploy_to_aws ? module.aws[0].database_endpoint : null
}

output "aws_ecr_repository" {
  description = "AWS ECR repository URL"
  value       = var.deploy_to_aws ? module.aws[0].ecr_repository_url : null
}

# Azure Outputs
output "azure_api_url" {
  description = "Azure API URL"
  value       = var.deploy_to_azure ? module.azure[0].container_app_url : null
}

output "azure_database_fqdn" {
  description = "Azure Database FQDN"
  value       = var.deploy_to_azure ? module.azure[0].database_fqdn : null
}

output "azure_acr_login_server" {
  description = "Azure Container Registry login server"
  value       = var.deploy_to_azure ? module.azure[0].acr_login_server : null
}

# GCP Outputs
output "gcp_api_url" {
  description = "GCP API URL"
  value       = var.deploy_to_gcp ? module.gcp[0].cloud_run_url : null
}

output "gcp_database_connection_name" {
  description = "GCP Database connection name"
  value       = var.deploy_to_gcp ? module.gcp[0].database_connection_name : null
}

output "gcp_artifact_registry" {
  description = "GCP Artifact Registry URL"
  value       = var.deploy_to_gcp ? module.gcp[0].artifact_registry_url : null
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of deployments"
  value = {
    aws_deployed   = var.deploy_to_aws
    azure_deployed = var.deploy_to_azure
    gcp_deployed   = var.deploy_to_gcp
    environment    = "dev"
  }
}