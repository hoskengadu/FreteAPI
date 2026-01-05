# ==========================================
# Common Module - Shared Resources
# ==========================================

# Docker image for the API
data "external" "docker_build" {
  program = ["bash", "-c", <<-EOF
    cd ${path.root}/../
    
    # Build the Docker image
    docker build -f Dockerfile -t ${var.project_name}:${var.api_version} .
    
    # Output the image name
    echo '{"image": "${var.project_name}:${var.api_version}"}'
  EOF
  ]
}

# Local values for common configurations
locals {
  common_labels = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
  })

  # Database configuration
  db_config = {
    name     = "${var.project_name}_${var.environment}"
    username = "freteapi"
    password = var.db_password
    port     = 5432
  }

  # Application configuration
  app_config = {
    name           = "${var.project_name}-api"
    image          = data.external.docker_build.result.image
    container_port = 8080
    health_path    = "/health"
  }
}

# Dockerfile for the API (to be placed in the root directory)
resource "local_file" "dockerfile" {
  filename = "${path.root}/../Dockerfile"
  content = templatefile("${path.module}/templates/Dockerfile.tpl", {
    project_name = var.project_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Docker compose for local development
resource "local_file" "docker_compose" {
  filename = "${path.root}/../docker-compose.yml"
  content = templatefile("${path.module}/templates/docker-compose.yml.tpl", {
    project_name    = var.project_name
    api_version     = var.api_version
    db_password     = var.db_password
    container_port  = local.app_config.container_port
  })
}

# Migration script
resource "local_file" "migration_script" {
  filename = "${path.root}/scripts/run-migrations.sh"
  content = templatefile("${path.module}/templates/run-migrations.sh.tpl", {
    project_name = var.project_name
    api_version  = var.api_version
  })

  provisioner "local-exec" {
    command = "chmod +x ${path.root}/scripts/run-migrations.sh"
  }
}

# Run migrations if requested
resource "null_resource" "run_migrations" {
  count = var.run_migrations ? 1 : 0

  provisioner "local-exec" {
    command = "${path.root}/scripts/run-migrations.sh"
    environment = {
      DB_HOST     = var.db_host
      DB_NAME     = local.db_config.name
      DB_USER     = local.db_config.username
      DB_PASSWORD = local.db_config.password
      DB_PORT     = local.db_config.port
    }
  }

  triggers = {
    # Re-run migrations if database connection changes
    db_host = var.db_host
    # Add timestamp to force re-run when needed
    timestamp = var.force_migration_run ? timestamp() : ""
  }
}