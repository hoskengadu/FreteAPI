# ==========================================
# Development Environment Configuration
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
  # Uncomment and configure for your preferred backend
  
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "freteapi/dev/terraform.tfstate"
  #   region = "us-east-1"
  # }
  
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "terraformstate"
  #   container_name       = "tfstate"
  #   key                  = "freteapi/dev/terraform.tfstate"
  # }
  
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "freteapi/dev"
  # }
}

# Local variables
locals {
  environment = "dev"
  name_prefix = "freteapi-dev"
  
  common_tags = {
    Environment = "dev"
    Project     = "FreteAPI"
    ManagedBy   = "Terraform"
    Owner       = "DevTeam"
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
      prevent_deletion_if_contains_resources = false
    }
    
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# ==========================================
# Multi-Cloud Deployment
# ==========================================

# AWS Deployment
module "aws" {
  count = var.deploy_to_aws ? 1 : 0
  
  source = "../../modules/aws"

  name_prefix      = local.name_prefix
  environment      = local.environment
  vpc_cidr        = "10.0.0.0/16"
  az_count        = 2

  # Database configuration
  database_name               = var.database_name
  database_username          = var.database_username
  database_password          = var.database_password
  rds_instance_class         = "db.t3.micro"
  rds_allocated_storage      = 20
  backup_retention_period    = 3
  rds_deletion_protection    = false

  # ECS configuration
  api_image       = var.api_image
  api_version     = var.api_version
  container_port  = 80
  ecs_cpu        = 256
  ecs_memory     = 512
  instance_count = 1
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

  # Database configuration
  database_name       = var.database_name
  database_username   = var.database_username
  database_password   = var.database_password
  database_sku       = "B_Standard_B1ms"
  database_storage_mb = 32768
  backup_retention_days = 3

  # Container App configuration
  api_image        = var.api_image
  api_version      = var.api_version
  container_port   = 80
  container_cpu    = 0.25
  container_memory = "0.5Gi"
  min_replicas     = 0
  max_replicas     = 5
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

  # Database configuration
  database_name        = var.database_name
  database_username    = var.database_username
  database_password    = var.database_password
  database_tier       = "db-f1-micro"
  database_disk_size  = 20
  backup_retention_days = 3

  # Cloud Run configuration
  api_image             = var.api_image
  api_version          = var.api_version
  container_port       = 80
  container_cpu       = "1000m"
  container_memory    = "1Gi"
  min_instances       = 0
  max_instances       = 5
  allow_unauthenticated = true
  run_migrations      = var.run_migrations

  # Monitoring
  enable_monitoring   = false
  notification_email  = ""

  labels = local.common_tags
}