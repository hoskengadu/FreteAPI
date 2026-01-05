# ==========================================
# GCP Module Variables
# ==========================================

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

# Database Configuration
variable "database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "freteapi"
}

variable "database_username" {
  description = "Master username for the database"
  type        = string
  default     = "freteapi"
}

variable "database_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "database_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "database_disk_size" {
  description = "Database disk size in GB"
  type        = number
  default     = 20
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
  
  validation {
    condition     = contains(["13", "14", "15"], var.postgres_version)
    error_message = "PostgreSQL version must be one of: 13, 14, 15."
  }
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

# Cloud Run Configuration
variable "api_image" {
  description = "Docker image for the API"
  type        = string
  default     = "freteapi:latest"
}

variable "api_image_name" {
  description = "Name for the API image in registry"
  type        = string
  default     = "freteapi"
}

variable "api_version" {
  description = "API version tag"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port the container exposes"
  type        = number
  default     = 80
}

variable "container_cpu" {
  description = "CPU allocation for container (e.g., '1000m' for 1 CPU)"
  type        = string
  default     = "1000m"
}

variable "container_memory" {
  description = "Memory allocation for container (e.g., '512Mi', '1Gi')"
  type        = string
  default     = "1Gi"
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated requests to Cloud Run service"
  type        = bool
  default     = true
}

variable "run_migrations" {
  description = "Whether to run database migrations on deployment"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Email address for monitoring notifications"
  type        = string
  default     = ""
}

# Common labels
variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}