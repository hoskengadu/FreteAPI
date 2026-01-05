#!/bin/bash

# ==========================================
# FreteAPI Multi-Cloud Destroy Script
# ==========================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
CLOUD_PROVIDER=""
FORCE="false"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment    Environment (dev|prod) [default: dev]"
    echo "  -c, --cloud         Cloud provider (aws|azure|gcp|all) [required]"
    echo "  -f, --force         Skip confirmation prompts [default: false]"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --environment dev --cloud aws"
    echo "  $0 -e dev -c all --force"
    echo ""
    echo "⚠️  WARNING: This will destroy all resources in the specified environment!"
}

# Function to confirm destruction
confirm_destruction() {
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi
    
    print_warning "⚠️  This will PERMANENTLY DESTROY all resources in the $ENVIRONMENT environment!"
    print_warning "This includes:"
    
    if [[ "$CLOUD_PROVIDER" == "aws" || "$CLOUD_PROVIDER" == "all" ]]; then
        echo "   - AWS ECS clusters, tasks, and services"
        echo "   - AWS RDS databases (with all data)"
        echo "   - AWS VPC, subnets, and security groups"
        echo "   - AWS Load Balancers and ECR repositories"
    fi
    
    if [[ "$CLOUD_PROVIDER" == "azure" || "$CLOUD_PROVIDER" == "all" ]]; then
        echo "   - Azure Container Apps"
        echo "   - Azure PostgreSQL databases (with all data)"
        echo "   - Azure Container Registry"
        echo "   - Azure Resource Groups"
    fi
    
    if [[ "$CLOUD_PROVIDER" == "gcp" || "$CLOUD_PROVIDER" == "all" ]]; then
        echo "   - GCP Cloud Run services"
        echo "   - GCP Cloud SQL databases (with all data)"
        echo "   - GCP Artifact Registry repositories"
        echo "   - GCP VPC networks"
    fi
    
    echo ""
    print_error "THIS ACTION CANNOT BE UNDONE!"
    echo ""
    
    read -p "Type 'DELETE' to confirm destruction: " confirmation
    if [[ "$confirmation" != "DELETE" ]]; then
        print_warning "Destruction cancelled by user"
        exit 0
    fi
    
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        print_error "PRODUCTION ENVIRONMENT DESTRUCTION!"
        read -p "Type 'DELETE-PRODUCTION' to confirm: " prod_confirmation
        if [[ "$prod_confirmation" != "DELETE-PRODUCTION" ]]; then
            print_warning "Production destruction cancelled"
            exit 0
        fi
    fi
}

# Function to destroy infrastructure
destroy_terraform() {
    local env_dir="$(dirname "$0")/../environments/$ENVIRONMENT"
    
    print_status "Starting Terraform destruction for $ENVIRONMENT environment..."
    
    # Check if environment directory exists
    if [[ ! -d "$env_dir" ]]; then
        print_error "Environment directory not found: $env_dir"
        exit 1
    fi
    
    cd "$env_dir"
    
    # Check if terraform.tfvars exists
    if [[ ! -f "terraform.tfvars" ]]; then
        print_error "terraform.tfvars not found. Cannot proceed with destruction."
        exit 1
    fi
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Plan destruction
    print_status "Planning destruction..."
    
    local tf_vars=""
    case "$CLOUD_PROVIDER" in
        "aws")
            tf_vars="-var='deploy_to_aws=true' -var='deploy_to_azure=false' -var='deploy_to_gcp=false'"
            ;;
        "azure")
            tf_vars="-var='deploy_to_aws=false' -var='deploy_to_azure=true' -var='deploy_to_gcp=false'"
            ;;
        "gcp")
            tf_vars="-var='deploy_to_aws=false' -var='deploy_to_azure=false' -var='deploy_to_gcp=true'"
            ;;
        "all")
            tf_vars="-var='deploy_to_aws=true' -var='deploy_to_azure=true' -var='deploy_to_gcp=true'"
            ;;
    esac
    
    # Set migrations to false for destruction
    tf_vars="$tf_vars -var='run_migrations=false'"
    
    eval terraform plan -destroy $tf_vars -out=destroy-plan
    
    # Execute destruction
    print_status "Executing destruction..."
    terraform apply destroy-plan
    
    print_success "Infrastructure destroyed successfully!"
    
    # Cleanup
    rm -f destroy-plan
    cd - > /dev/null
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -c|--cloud)
            CLOUD_PROVIDER="$2"
            shift 2
            ;;
        -f|--force)
            FORCE="true"
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$CLOUD_PROVIDER" ]]; then
    print_error "Cloud provider is required"
    show_usage
    exit 1
fi

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
    print_error "Environment must be 'dev' or 'prod'"
    exit 1
fi

if [[ "$CLOUD_PROVIDER" != "aws" && "$CLOUD_PROVIDER" != "azure" && "$CLOUD_PROVIDER" != "gcp" && "$CLOUD_PROVIDER" != "all" ]]; then
    print_error "Cloud provider must be 'aws', 'azure', 'gcp', or 'all'"
    exit 1
fi

# Main execution
print_status "Starting FreteAPI infrastructure destruction..."
print_status "Environment: $ENVIRONMENT"
print_status "Cloud Provider: $CLOUD_PROVIDER"
echo

confirm_destruction
destroy_terraform

print_success "FreteAPI infrastructure destruction completed!"
print_warning "Remember to:"
print_warning "- Clean up any manual resources not managed by Terraform"
print_warning "- Verify all resources have been destroyed in the cloud console"
print_warning "- Remove any remaining storage buckets or containers"