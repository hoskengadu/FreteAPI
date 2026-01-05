# ==========================================
# Common Module Outputs
# ==========================================

output "api_image" {
  description = "Docker image for the API"
  value       = local.app_config.image
}

output "api_name" {
  description = "Application name"
  value       = local.app_config.name
}

output "container_port" {
  description = "Container port"
  value       = local.app_config.container_port
}

output "health_path" {
  description = "Health check path"
  value       = local.app_config.health_path
}

output "db_config" {
  description = "Database configuration"
  value = {
    name     = local.db_config.name
    username = local.db_config.username
    port     = local.db_config.port
  }
  sensitive = false
}

output "common_labels" {
  description = "Common labels for resources"
  value       = local.common_labels
}