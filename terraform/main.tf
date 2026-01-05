# ==========================================
# FreteAPI - Multi-Cloud Terraform
# ==========================================

terraform {
  required_version = ">= 1.0"
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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  # Backend configuration should be provided via backend config file
  # Example: terraform init -backend-config=backend.hcl
}

# Random password for database
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Common module for shared resources
module "common" {
  source = "./modules/common"

  project_name    = var.project_name
  environment     = var.environment
  api_version     = var.api_version
  db_password     = random_password.db_password.result
  run_migrations  = var.run_migrations
  
  tags = var.tags
}

# Conditional AWS deployment
module "aws" {
  count  = var.cloud_provider == "aws" || var.cloud_provider == "multi" ? 1 : 0
  source = "./modules/aws"

  project_name       = var.project_name
  environment        = var.environment
  region            = var.aws_region
  api_image         = module.common.api_image
  db_password       = random_password.db_password.result
  container_port    = var.container_port
  instance_count    = var.instance_count
  run_migrations    = var.run_migrations
  
  tags = var.tags
}

# Conditional Azure deployment  
module "azure" {
  count  = var.cloud_provider == "azure" || var.cloud_provider == "multi" ? 1 : 0
  source = "./modules/azure"

  project_name       = var.project_name
  environment        = var.environment
  location          = var.azure_location
  api_image         = module.common.api_image
  db_password       = random_password.db_password.result
  container_port    = var.container_port
  instance_count    = var.instance_count
  run_migrations    = var.run_migrations
  
  tags = var.tags
}

# Conditional GCP deployment
module "gcp" {
  count  = var.cloud_provider == "gcp" || var.cloud_provider == "multi" ? 1 : 0
  source = "./modules/gcp"

  project_name       = var.project_name
  environment        = var.environment
  project_id        = var.gcp_project_id
  region            = var.gcp_region
  api_image         = module.common.api_image
  db_password       = random_password.db_password.result
  container_port    = var.container_port
  instance_count    = var.instance_count
  run_migrations    = var.run_migrations
  
  tags = var.tags
}