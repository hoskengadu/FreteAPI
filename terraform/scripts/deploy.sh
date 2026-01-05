#!/bin/bash

# ==========================================
# FreteAPI Multi-Cloud Deployment Script
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
BUILD_IMAGE="true"
RUN_MIGRATIONS="true"

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
    echo "  -b, --build         Build Docker image (true|false) [default: true]"
    echo "  -m, --migrate       Run database migrations (true|false) [default: true]"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --environment dev --cloud aws"
    echo "  $0 -e prod -c azure --build true"
    echo "  $0 --environment dev --cloud all"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Docker is installed and running
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running"
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed or not in PATH"
        exit 1
    fi
    
    # Check cloud CLI tools based on provider
    if [[ "$CLOUD_PROVIDER" == "aws" || "$CLOUD_PROVIDER" == "all" ]]; then
        if ! command -v aws &> /dev/null; then
            print_warning "AWS CLI is not installed. Required for AWS deployment."
        fi
    fi
    
    if [[ "$CLOUD_PROVIDER" == "azure" || "$CLOUD_PROVIDER" == "all" ]]; then
        if ! command -v az &> /dev/null; then
            print_warning "Azure CLI is not installed. Required for Azure deployment."
        fi
    fi
    
    if [[ "$CLOUD_PROVIDER" == "gcp" || "$CLOUD_PROVIDER" == "all" ]]; then
        if ! command -v gcloud &> /dev/null; then
            print_warning "Google Cloud CLI is not installed. Required for GCP deployment."
        fi
    fi
    
    print_success "Prerequisites check completed"
}

# Function to build Docker image
build_docker_image() {
    if [[ "$BUILD_IMAGE" == "true" ]]; then
        print_status "Building Docker image..."
        
        cd "$(dirname "$0")/../../"
        
        # Build the image
        docker build -t freteapi:latest -f Dockerfile .
        
        # Tag with version
        docker tag freteapi:latest freteapi:v1.0.0
        
        print_success "Docker image built successfully"
        cd - > /dev/null
    else
        print_status "Skipping Docker image build"
    fi
}

# Function to deploy to cloud
deploy_terraform() {
    local env_dir="$(dirname "$0")/../environments/$ENVIRONMENT"
    
    print_status "Starting Terraform deployment for $ENVIRONMENT environment..."
    
    # Check if environment directory exists
    if [[ ! -d "$env_dir" ]]; then
        print_error "Environment directory not found: $env_dir"
        exit 1
    fi
    
    cd "$env_dir"
    
    # Check if terraform.tfvars exists
    if [[ ! -f "terraform.tfvars" ]]; then
        print_warning "terraform.tfvars not found. Please create it from terraform.tfvars.example"
        if [[ -f "terraform.tfvars.example" ]]; then
            print_status "Copying terraform.tfvars.example to terraform.tfvars..."
            cp terraform.tfvars.example terraform.tfvars
            print_warning "Please edit terraform.tfvars with your actual values before proceeding"
            exit 1
        fi
    fi
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Validate configuration
    print_status "Validating Terraform configuration..."
    terraform validate
    
    # Plan deployment
    print_status "Planning deployment..."
    
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
    
    # Add migration variable
    tf_vars="$tf_vars -var='run_migrations=$RUN_MIGRATIONS'"
    
    eval terraform plan $tf_vars -out=tfplan
    
    # Apply configuration
    print_status "Applying Terraform configuration..."
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply tfplan
        print_success "Deployment completed successfully!"
        
        # Show outputs
        print_status "Deployment outputs:"
        terraform output
    else
        print_warning "Deployment cancelled by user"
        rm -f tfplan
        exit 0
    fi
    
    # Cleanup
    rm -f tfplan
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
        -b|--build)
            BUILD_IMAGE="$2"
            shift 2
            ;;
        -m|--migrate)
            RUN_MIGRATIONS="$2"
            shift 2
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
print_status "Starting FreteAPI deployment..."
print_status "Environment: $ENVIRONMENT"
print_status "Cloud Provider: $CLOUD_PROVIDER"
print_status "Build Image: $BUILD_IMAGE"
print_status "Run Migrations: $RUN_MIGRATIONS"
echo

check_prerequisites
build_docker_image
deploy_terraform

print_success "FreteAPI deployment completed successfully!"