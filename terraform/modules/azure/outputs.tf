# ==========================================
# Azure Module Outputs
# ==========================================

# Resource Group
output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Resource group location"
  value       = azurerm_resource_group.main.location
}

# Container Registry
output "acr_login_server" {
  description = "Container Registry login server URL"
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  description = "Container Registry admin username"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

# Database
output "database_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_name" {
  description = "Database name"
  value       = azurerm_postgresql_flexible_server_database.main.name
}

output "database_username" {
  description = "Database username"
  value       = azurerm_postgresql_flexible_server.main.administrator_login
  sensitive   = true
}

# Container App
output "container_app_fqdn" {
  description = "Container App FQDN"
  value       = azurerm_container_app.api.latest_revision_fqdn
}

output "container_app_url" {
  description = "Container App URL"
  value       = "https://${azurerm_container_app.api.latest_revision_fqdn}"
}

output "container_app_name" {
  description = "Container App name"
  value       = azurerm_container_app.api.name
}

# Monitoring
output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

# Security
output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "container_app_identity_principal_id" {
  description = "Container App managed identity principal ID"
  value       = azurerm_container_app.api.identity[0].principal_id
}