# ==========================================
# Azure Main Module - Container Apps
# ==========================================

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.name_prefix}-rg"
  location = var.location

  tags = var.tags
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = "${replace(var.name_prefix, "-", "")}acr"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  sku                = var.acr_sku
  admin_enabled      = true

  tags = var.tags
}

# Push Docker image to ACR
resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = <<-EOF
      # Login to ACR
      az acr login --name ${azurerm_container_registry.main.name}
      
      # Tag and push image
      docker tag ${var.api_image} ${azurerm_container_registry.main.login_server}/${var.api_image_name}:${var.api_version}
      docker tag ${var.api_image} ${azurerm_container_registry.main.login_server}/${var.api_image_name}:latest
      
      docker push ${azurerm_container_registry.main.login_server}/${var.api_image_name}:${var.api_version}
      docker push ${azurerm_container_registry.main.login_server}/${var.api_image_name}:latest
    EOF
  }

  depends_on = [azurerm_container_registry.main]
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.name_prefix}-postgres"
  resource_group_name    = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  version               = var.postgres_version
  administrator_login    = var.database_username
  administrator_password = var.database_password
  storage_mb            = var.database_storage_mb
  sku_name              = var.database_sku

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.environment == "prod" ? true : false
  zone                        = "1"

  high_availability {
    mode                      = var.environment == "prod" ? "ZoneRedundant" : "Disabled"
    standby_availability_zone = var.environment == "prod" ? "2" : null
  }

  tags = var.tags
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Container App Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "${var.name_prefix}-env"
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name_prefix}-logs"
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                = "PerGB2018"
  retention_in_days  = 30

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${var.name_prefix}-insights"
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id       = azurerm_log_analytics_workspace.main.id
  application_type   = "web"

  tags = var.tags
}

# Container App
resource "azurerm_container_app" "api" {
  name                         = "${var.name_prefix}-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name         = azurerm_resource_group.main.name
  revision_mode               = "Single"

  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    username = azurerm_container_registry.main.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.main.admin_password
  }

  secret {
    name  = "connection-string"
    value = "Host=${azurerm_postgresql_flexible_server.main.fqdn};Database=${var.database_name};Username=${var.database_username};Password=${var.database_password};Port=5432;SSL Mode=Require;"
  }

  template {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    revision_suffix = var.api_version

    container {
      name   = "api"
      image  = "${azurerm_container_registry.main.login_server}/${var.api_image_name}:${var.api_version}"
      cpu    = var.container_cpu
      memory = var.container_memory

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment == "prod" ? "Production" : "Development"
      }

      env {
        name  = "ASPNETCORE_URLS"
        value = "http://+:${var.container_port}"
      }

      env {
        name        = "ConnectionStrings__DefaultConnection"
        secret_name = "connection-string"
      }

      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.main.connection_string
      }

      # Health probe
      liveness_probe {
        transport = "HTTP"
        port      = var.container_port
        path      = "/health"
      }

      readiness_probe {
        transport = "HTTP"
        port      = var.container_port
        path      = "/health/ready"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = var.container_port
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags

  depends_on = [
    null_resource.docker_push,
    null_resource.run_migrations
  ]
}

# Run database migrations
resource "null_resource" "run_migrations" {
  count = var.run_migrations ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOF
      # Create a temporary container to run migrations
      docker run --rm \
        -e ConnectionStrings__DefaultConnection="Host=${azurerm_postgresql_flexible_server.main.fqdn};Database=${var.database_name};Username=${var.database_username};Password=${var.database_password};Port=5432;SSL Mode=Require;" \
        ${var.api_image} \
        dotnet ef database update --no-build --verbose
    EOF
  }

  depends_on = [
    azurerm_postgresql_flexible_server_database.main
  ]
}

# Key Vault for secrets management (optional but recommended)
resource "azurerm_key_vault" "main" {
  name                = "${var.name_prefix}-kv"
  location           = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  sku_name           = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore"
    ]
  }

  # Allow Container App to access secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_container_app.api.identity[0].principal_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }

  tags = var.tags
}

# Store database connection string in Key Vault
resource "azurerm_key_vault_secret" "db_connection" {
  name         = "database-connection-string"
  value        = "Host=${azurerm_postgresql_flexible_server.main.fqdn};Database=${var.database_name};Username=${var.database_username};Password=${var.database_password};Port=5432;SSL Mode=Require;"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_postgresql_flexible_server.main]
}

# Data sources
data "azurerm_client_config" "current" {}