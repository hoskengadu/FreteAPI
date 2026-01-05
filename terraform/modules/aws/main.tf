# ==========================================
# AWS Main Module
# ==========================================

# Network Infrastructure
module "network" {
  source = "./network"

  name_prefix           = var.name_prefix
  environment          = var.environment
  vpc_cidr            = var.vpc_cidr
  az_count            = var.az_count
  allowed_cidr_blocks = var.allowed_cidr_blocks
  tags                = var.tags
}

# RDS Database
module "rds" {
  source = "./rds"

  name_prefix               = var.name_prefix
  environment              = var.environment
  vpc_id                   = module.network.vpc_id
  subnet_group_name        = module.network.database_subnet_group_name
  security_group_id        = module.network.rds_security_group_id
  database_name           = var.database_name
  database_username       = var.database_username
  database_password       = var.database_password
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  deletion_protection    = var.rds_deletion_protection
  monitoring_interval    = var.monitoring_interval
  tags                   = var.tags
}

# ECS with Fargate
module "ecs" {
  source = "./ecs"

  name_prefix            = var.name_prefix
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
  ecs_security_group_id = module.network.ecs_security_group_id
  api_image             = var.api_image
  api_version           = var.api_version
  container_port        = var.container_port
  cpu                   = var.ecs_cpu
  memory                = var.ecs_memory
  instance_count        = var.instance_count
  db_host               = module.rds.endpoint
  db_name               = var.database_name
  db_password           = var.database_password
  run_migrations        = var.run_migrations
  tags                  = var.tags

  depends_on = [module.rds]
}