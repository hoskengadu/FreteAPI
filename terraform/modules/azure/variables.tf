# ==========================================
# Azure Module Variables
# ==========================================

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

variable "location" {
  description = "Azure location"
  type        = string
  default     = "East US"
}

# Container Registry
variable "acr_sku" {
  description = "Container Registry SKU"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be one of: Basic, Standard, Premium."
  }
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

variable "database_sku" {
  description = "PostgreSQL Flexible Server SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "database_storage_mb" {
  description = "Storage size in MB for PostgreSQL"
  type        = number
  default     = 32768
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

# Container App Configuration
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
  description = "CPU allocation for container (0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0)"
  type        = number
  default     = 0.5
  
  validation {
    condition     = contains([0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], var.container_cpu)
    error_message = "Container CPU must be one of the valid values."
  }
}

variable "container_memory" {
  description = "Memory allocation for container (0.5Gi, 1Gi, 1.5Gi, 2Gi, 3Gi, 4Gi)"
  type        = string
  default     = "1Gi"
  
  validation {
    condition     = contains(["0.5Gi", "1Gi", "1.5Gi", "2Gi", "3Gi", "4Gi"], var.container_memory)
    error_message = "Container memory must be one of the valid values."
  }
}

variable "min_replicas" {
  description = "Minimum number of container replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of container replicas"
  type        = number
  default     = 10
}

variable "run_migrations" {
  description = "Whether to run database migrations on deployment"
  type        = bool
  default     = true
}

# Common tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}