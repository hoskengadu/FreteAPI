# ==========================================
# Providers Configuration
# ==========================================

# AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  
  default_tags {
    tags = merge(var.tags, {
      Provider = "AWS"
    })
  }
}

# Azure Provider
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
  
  subscription_id = var.azure_subscription_id != "" ? var.azure_subscription_id : null
}

# Google Cloud Provider
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  
  default_labels = merge(
    { for k, v in var.tags : lower(k) => lower(v) },
    {
      provider = "gcp"
    }
  )
}