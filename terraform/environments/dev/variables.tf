# ==========================================
# Development Environment Variables
# ==========================================

# Cloud Provider Selection
variable "deploy_to_aws" {
  description = "Deploy to AWS"
  type        = bool
  default     = true
}

variable "deploy_to_azure" {
  description = "Deploy to Azure"
  type        = bool
  default     = false
}

variable "deploy_to_gcp" {
  description = "Deploy to GCP"
  type        = bool
  default     = false
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Azure Configuration
variable "azure_location" {
  description = "Azure location"
  type        = string
  default     = "East US"
}

# GCP Configuration
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

# Application Configuration
variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "freteapi"
}

variable "database_username" {
  description = "Database master username"
  type        = string
  default     = "freteapi"
}

variable "database_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "api_image" {
  description = "Docker image for the API"
  type        = string
  default     = "freteapi:latest"
}

variable "api_version" {
  description = "API version tag"
  type        = string
  default     = "v1.0.0"
}

variable "run_migrations" {
  description = "Whether to run database migrations"
  type        = bool
  default     = true
}