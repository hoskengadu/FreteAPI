# ==========================================
# Variables - Multi-Cloud Configuration
# ==========================================

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "freteapi"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "cloud_provider" {
  description = "Cloud provider to deploy to (aws, azure, gcp, multi)"
  type        = string
  default     = "aws"
  validation {
    condition = contains(["aws", "azure", "gcp", "multi"], var.cloud_provider)
    error_message = "Cloud provider must be aws, azure, gcp, or multi."
  }
}

# ==========================================
# API Configuration
# ==========================================

variable "api_version" {
  description = "API Docker image version/tag"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port that the API container listens on"
  type        = number
  default     = 8080
}

variable "instance_count" {
  description = "Number of API instances to run"
  type        = number
  default     = 2
}

variable "run_migrations" {
  description = "Whether to run database migrations on this deployment"
  type        = bool
  default     = false
}

# ==========================================
# AWS Configuration
# ==========================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "default"
}

# ==========================================
# Azure Configuration
# ==========================================

variable "azure_location" {
  description = "Azure location"
  type        = string
  default     = "East US"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = ""
}

# ==========================================
# GCP Configuration
# ==========================================

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

# ==========================================
# Database Configuration
# ==========================================

variable "db_instance_class" {
  description = "Database instance class/size"
  type        = string
  default     = "small"
  validation {
    condition = contains(["micro", "small", "medium", "large"], var.db_instance_class)
    error_message = "DB instance class must be micro, small, medium, or large."
  }
}

variable "db_allocated_storage" {
  description = "Database allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_backup_retention" {
  description = "Database backup retention period in days"
  type        = number
  default     = 7
}

# ==========================================
# Network Configuration
# ==========================================

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the API"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change in production
}

variable "enable_https" {
  description = "Enable HTTPS/SSL termination"
  type        = bool
  default     = true
}

# ==========================================
# Monitoring & Logging
# ==========================================

variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

# ==========================================
# Tags
# ==========================================

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "FreteAPI"
    ManagedBy = "Terraform"
    Owner     = "DevOps"
  }
}