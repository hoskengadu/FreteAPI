# ==========================================
# GCP Main Module - Cloud Run
# ==========================================

# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "monitoring.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

# Artifact Registry for Docker images
resource "google_artifact_registry_repository" "main" {
  repository_id = "${var.name_prefix}-repo"
  location      = var.region
  format        = "DOCKER"
  project       = var.project_id

  description = "Docker repository for ${var.name_prefix} API"

  labels = var.labels

  depends_on = [google_project_service.apis]
}

# Push Docker image to Artifact Registry
resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = <<-EOF
      # Configure Docker for Artifact Registry
      gcloud auth configure-docker ${var.region}-docker.pkg.dev
      
      # Tag and push image
      docker tag ${var.api_image} ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.api_image_name}:${var.api_version}
      docker tag ${var.api_image} ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.api_image_name}:latest
      
      docker push ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.api_image_name}:${var.api_version}
      docker push ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.api_image_name}:latest
    EOF
  }

  depends_on = [google_artifact_registry_repository.main]
}

# Cloud SQL instance
resource "google_sql_database_instance" "main" {
  name             = "${var.name_prefix}-db"
  database_version = "POSTGRES_${var.postgres_version}"
  region          = var.region
  project         = var.project_id

  deletion_protection = var.environment == "prod"

  settings {
    tier              = var.database_tier
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = var.database_disk_size
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = var.environment == "prod"
      backup_retention_settings {
        retained_backups = var.backup_retention_days
      }
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.vpc.id
      require_ssl     = true
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }

    maintenance_window {
      day          = 7  # Sunday
      hour         = 4  # 4 AM
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }
  }

  depends_on = [
    google_project_service.apis,
    google_compute_network.vpc,
    google_compute_global_address.private_ip
  ]
}

# Cloud SQL database
resource "google_sql_database" "main" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# Cloud SQL user
resource "google_sql_user" "main" {
  name     = var.database_username
  instance = google_sql_database_instance.main.name
  password = var.database_password
  project  = var.project_id
}

# VPC Network for private services access
resource "google_compute_network" "vpc" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id

  depends_on = [google_project_service.apis]
}

# Private services access
resource "google_compute_global_address" "private_ip" {
  name          = "${var.name_prefix}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}

# Secret Manager secrets
resource "google_secret_manager_secret" "db_connection" {
  secret_id = "${var.name_prefix}-db-connection"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "db_connection" {
  secret = google_secret_manager_secret.db_connection.id
  secret_data = "Host=${google_sql_database_instance.main.private_ip_address};Database=${var.database_name};Username=${var.database_username};Password=${var.database_password};Port=5432;SSL Mode=Require;"
}

# Cloud Run service account
resource "google_service_account" "cloudrun" {
  account_id   = "${var.name_prefix}-cloudrun"
  display_name = "Cloud Run service account for ${var.name_prefix}"
  project      = var.project_id
}

# IAM bindings for Cloud Run service account
resource "google_project_iam_member" "cloudrun_secrets" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

resource "google_project_iam_member" "cloudrun_cloudsql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

resource "google_project_iam_member" "cloudrun_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# Cloud Run service
resource "google_cloud_run_v2_service" "api" {
  name     = "${var.name_prefix}-api"
  location = var.region
  project  = var.project_id

  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloudrun.email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      name  = "api"
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.api_image_name}:${var.api_version}"

      ports {
        container_port = var.container_port
      }

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment == "prod" ? "Production" : "Development"
      }

      env {
        name  = "ASPNETCORE_URLS"
        value = "http://+:${var.container_port}"
      }

      env {
        name = "ConnectionStrings__DefaultConnection"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_connection.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }

      resources {
        limits = {
          cpu    = var.container_cpu
          memory = var.container_memory
        }
        startup_cpu_boost = true
      }

      startup_probe {
        http_get {
          path = "/health"
          port = var.container_port
        }
        initial_delay_seconds = 10
        timeout_seconds       = 10
        period_seconds       = 10
        failure_threshold    = 3
      }

      liveness_probe {
        http_get {
          path = "/health"
          port = var.container_port
        }
        initial_delay_seconds = 30
        timeout_seconds       = 10
        period_seconds       = 30
        failure_threshold    = 3
      }
    }

    vpc_access {
      network_interfaces {
        network    = google_compute_network.vpc.name
        subnetwork = google_compute_subnetwork.subnet.name
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = var.labels

  depends_on = [
    null_resource.docker_push,
    null_resource.run_migrations,
    google_project_service.apis
  ]
}

# Subnetwork for Cloud Run
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# Cloud Run IAM policy (allow public access)
resource "google_cloud_run_service_iam_binding" "public" {
  location = google_cloud_run_v2_service.api.location
  project  = google_cloud_run_v2_service.api.project
  service  = google_cloud_run_v2_service.api.name
  role     = "roles/run.invoker"
  members  = var.allow_unauthenticated ? ["allUsers"] : []
}

# Run database migrations
resource "null_resource" "run_migrations" {
  count = var.run_migrations ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOF
      # Create a temporary container to run migrations
      # Using Cloud SQL Proxy for secure connection
      docker run --rm \
        -e ConnectionStrings__DefaultConnection="Host=${google_sql_database_instance.main.private_ip_address};Database=${var.database_name};Username=${var.database_username};Password=${var.database_password};Port=5432;SSL Mode=Require;" \
        ${var.api_image} \
        dotnet ef database update --no-build --verbose
    EOF
  }

  depends_on = [
    google_sql_database.main,
    google_sql_user.main,
    google_service_networking_connection.private_connection
  ]
}

# Monitoring - Uptime check
resource "google_monitoring_uptime_check_config" "api_check" {
  count = var.enable_monitoring ? 1 : 0

  display_name = "${var.name_prefix} API Uptime Check"
  timeout      = "10s"
  period       = "300s"
  project      = var.project_id

  http_check {
    path           = "/health"
    port           = "443"
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = google_cloud_run_v2_service.api.uri
    }
  }
}

# Monitoring - Notification channel (email)
resource "google_monitoring_notification_channel" "email" {
  count = var.enable_monitoring && var.notification_email != "" ? 1 : 0

  display_name = "${var.name_prefix} Email Notifications"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = var.notification_email
  }
}

# Alerting policy for uptime
resource "google_monitoring_alert_policy" "uptime" {
  count = var.enable_monitoring ? 1 : 0

  display_name = "${var.name_prefix} API Uptime Alert"
  project      = var.project_id

  conditions {
    display_name = "API is down"
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" resource.type=\"uptime_url\""
      duration        = "300s"
      comparison      = "COMPARISON_LESS_THAN"
      threshold_value = 1

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_FRACTION_TRUE"
      }
    }
  }

  notification_channels = var.notification_email != "" ? [google_monitoring_notification_channel.email[0].name] : []

  alert_strategy {
    auto_close = "604800s" # 7 days
  }
}