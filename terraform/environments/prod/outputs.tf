# ==========================================
# Production Environment Outputs
# ==========================================

# AWS Outputs
output "aws_api_url" {
  description = "AWS API URL"
  value       = var.deploy_to_aws ? "http://${module.aws[0].load_balancer_dns}" : null
}

output "aws_database_endpoint" {
  description = "AWS Database endpoint"
  value       = var.deploy_to_aws ? module.aws[0].database_endpoint : null
  sensitive   = true
}

output "aws_ecr_repository" {
  description = "AWS ECR repository URL"
  value       = var.deploy_to_aws ? module.aws[0].ecr_repository_url : null
}

output "aws_cluster_name" {
  description = "AWS ECS cluster name"
  value       = var.deploy_to_aws ? module.aws[0].cluster_name : null
}

# Azure Outputs
output "azure_api_url" {
  description = "Azure API URL"
  value       = var.deploy_to_azure ? module.azure[0].container_app_url : null
}

output "azure_database_fqdn" {
  description = "Azure Database FQDN"
  value       = var.deploy_to_azure ? module.azure[0].database_fqdn : null
  sensitive   = true
}

output "azure_acr_login_server" {
  description = "Azure Container Registry login server"
  value       = var.deploy_to_azure ? module.azure[0].acr_login_server : null
}

output "azure_container_app_name" {
  description = "Azure Container App name"
  value       = var.deploy_to_azure ? module.azure[0].container_app_name : null
}

# GCP Outputs
output "gcp_api_url" {
  description = "GCP API URL"
  value       = var.deploy_to_gcp ? module.gcp[0].cloud_run_url : null
}

output "gcp_database_connection_name" {
  description = "GCP Database connection name"
  value       = var.deploy_to_gcp ? module.gcp[0].database_connection_name : null
  sensitive   = true
}

output "gcp_artifact_registry" {
  description = "GCP Artifact Registry URL"
  value       = var.deploy_to_gcp ? module.gcp[0].artifact_registry_url : null
}

output "gcp_service_name" {
  description = "GCP Cloud Run service name"
  value       = var.deploy_to_gcp ? module.gcp[0].cloud_run_service_name : null
}

# Production Deployment Summary
output "production_deployment_summary" {
  description = "Production deployment summary with important information"
  value = {
    environment    = "prod"
    aws_deployed   = var.deploy_to_aws
    azure_deployed = var.deploy_to_azure
    gcp_deployed   = var.deploy_to_gcp
    
    api_endpoints = {
      aws   = var.deploy_to_aws ? "http://${module.aws[0].load_balancer_dns}" : "Not deployed"
      azure = var.deploy_to_azure ? module.azure[0].container_app_url : "Not deployed"
      gcp   = var.deploy_to_gcp ? module.gcp[0].cloud_run_url : "Not deployed"
    }
    
    monitoring = {
      aws_cloudwatch = var.deploy_to_aws ? "Enabled" : "Not deployed"
      azure_insights = var.deploy_to_azure ? "Enabled" : "Not deployed"
      gcp_monitoring = var.deploy_to_gcp ? "Enabled" : "Not deployed"
    }
    
    backup_retention = {
      aws   = var.deploy_to_aws ? "30 days" : "Not deployed"
      azure = var.deploy_to_azure ? "30 days" : "Not deployed"
      gcp   = var.deploy_to_gcp ? "30 days" : "Not deployed"
    }
  }
}