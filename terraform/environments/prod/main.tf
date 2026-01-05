# ==========================================
# Production Environment Configuration
# ==========================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Configure backend for state management
  # IMPORTANT: Configure this for production
  
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "freteapi/prod/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-lock"
  # }
  
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "terraformstateprod"
  #   container_name       = "tfstate"
  #   key                  = "freteapi/prod/terraform.tfstate"
  # }
  
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket-prod"
  #   prefix = "freteapi/prod"
  # }
}

# Local variables
locals {
  environment = "prod"
  name_prefix = "freteapi-prod"
  
  common_tags = {
    Environment = "prod"
    Project     = "FreteAPI"
    ManagedBy   = "Terraform"
    Owner       = "ProdTeam"
    Backup      = "Required"
    Monitoring  = "Critical"
  }
}

# ==========================================
# Providers Configuration
# ==========================================

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# ==========================================
# Multi-Cloud Production Deployment
# ==========================================

# AWS Deployment
module "aws" {
  count = var.deploy_to_aws ? 1 : 0
  
  source = "../../modules/aws"

  name_prefix      = local.name_prefix
  environment      = local.environment
  vpc_cidr        = "10.0.0.0/16"
  az_count        = 3  # More AZs for production

  # Database configuration - Production settings
  database_name               = var.database_name
  database_username          = var.database_username
  database_password          = var.database_password
  rds_instance_class         = "db.t3.small"  # Larger instance
  rds_allocated_storage      = 100
  backup_retention_period    = 30  # 30 days backup
  rds_deletion_protection    = true  # Protection enabled

  # ECS configuration - Production settings
  api_image       = var.api_image
  api_version     = var.api_version
  container_port  = 80
  ecs_cpu        = 512  # More CPU
  ecs_memory     = 1024  # More memory
  instance_count = 3    # More instances
  run_migrations = var.run_migrations

  tags = local.common_tags
}

# Azure Deployment
module "azure" {
  count = var.deploy_to_azure ? 1 : 0
  
  source = "../../modules/azure"

  name_prefix = local.name_prefix
  environment = local.environment
  location    = var.azure_location

  # Database configuration - Production settings
  database_name       = var.database_name
  database_username   = var.database_username
  database_password   = var.database_password
  database_sku       = "GP_Standard_D2s_v3"  # General Purpose
  database_storage_mb = 131072  # 128GB
  backup_retention_days = 30

  # Container App configuration - Production settings
  api_image        = var.api_image
  api_version      = var.api_version
  container_port   = 80
  container_cpu    = 1.0  # More CPU
  container_memory = "2Gi"  # More memory
  min_replicas     = 2    # Always running
  max_replicas     = 20   # Higher scale
  run_migrations   = var.run_migrations

  tags = local.common_tags
}

# GCP Deployment
module "gcp" {
  count = var.deploy_to_gcp ? 1 : 0
  
  source = "../../modules/gcp"

  project_id   = var.gcp_project_id
  name_prefix  = local.name_prefix
  environment  = local.environment
  region       = var.gcp_region

  # Database configuration - Production settings
  database_name        = var.database_name
  database_username    = var.database_username
  database_password    = var.database_password
  database_tier       = "db-standard-2"  # Standard instance
  database_disk_size  = 100
  backup_retention_days = 30

  # Cloud Run configuration - Production settings
  api_image             = var.api_image
  api_version          = var.api_version
  container_port       = 80
  container_cpu       = "2000m"  # 2 CPUs
  container_memory    = "4Gi"    # 4GB memory
  min_instances       = 1       # Always warm
  max_instances       = 100     # High scale
  allow_unauthenticated = true
  run_migrations      = var.run_migrations

  # Monitoring - Enabled for production
  enable_monitoring   = true
  notification_email  = var.notification_email

  labels = local.common_tags
}