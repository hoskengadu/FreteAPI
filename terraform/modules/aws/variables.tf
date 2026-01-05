# ==========================================
# AWS Module Variables
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

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
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

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS"
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval"
  type        = number
  default     = 60
}

# ECS Configuration
variable "api_image" {
  description = "Docker image for the API"
  type        = string
  default     = "freteapi:latest"
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

variable "ecs_cpu" {
  description = "CPU units for ECS tasks (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
  
  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.ecs_cpu)
    error_message = "CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "ecs_memory" {
  description = "Memory for ECS tasks in MB"
  type        = number
  default     = 512
}

variable "instance_count" {
  description = "Number of ECS instances to run"
  type        = number
  default     = 2
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