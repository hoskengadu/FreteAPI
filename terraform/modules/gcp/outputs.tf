# ==========================================
# GCP Module Outputs
# ==========================================

# Project Information
output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.region
}

# Artifact Registry
output "artifact_registry_repository" {
  description = "Artifact Registry repository name"
  value       = google_artifact_registry_repository.main.repository_id
}

output "artifact_registry_url" {
  description = "Artifact Registry URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}"
}

# Cloud SQL
output "database_connection_name" {
  description = "Cloud SQL connection name"
  value       = google_sql_database_instance.main.connection_name
}

output "database_private_ip" {
  description = "Cloud SQL private IP address"
  value       = google_sql_database_instance.main.private_ip_address
}

output "database_public_ip" {
  description = "Cloud SQL public IP address"
  value       = google_sql_database_instance.main.ip_address.0.ip_address
}

output "database_name" {
  description = "Database name"
  value       = google_sql_database.main.name
}

output "database_username" {
  description = "Database username"
  value       = google_sql_user.main.name
  sensitive   = true
}

# Cloud Run
output "cloud_run_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.api.uri
}

output "cloud_run_service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_v2_service.api.name
}

output "cloud_run_location" {
  description = "Cloud Run service location"
  value       = google_cloud_run_v2_service.api.location
}

# Service Account
output "service_account_email" {
  description = "Cloud Run service account email"
  value       = google_service_account.cloudrun.email
}

# Networking
output "vpc_network_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "vpc_subnet_name" {
  description = "VPC subnet name"
  value       = google_compute_subnetwork.subnet.name
}

# Secrets
output "db_connection_secret_name" {
  description = "Database connection secret name"
  value       = google_secret_manager_secret.db_connection.secret_id
}

# Monitoring
output "uptime_check_id" {
  description = "Uptime check ID"
  value       = var.enable_monitoring ? google_monitoring_uptime_check_config.api_check[0].name : null
}

output "notification_channel_name" {
  description = "Monitoring notification channel name"
  value       = var.enable_monitoring && var.notification_email != "" ? google_monitoring_notification_channel.email[0].name : null
}