# ==========================================
# Common Module Variables
# ==========================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "api_version" {
  description = "API version/tag"
  type        = string
  default     = "latest"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database host for migrations"
  type        = string
  default     = ""
}

variable "run_migrations" {
  description = "Whether to run database migrations"
  type        = bool
  default     = false
}

variable "force_migration_run" {
  description = "Force migration run even if already executed"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}