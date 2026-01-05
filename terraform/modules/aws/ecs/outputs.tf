# ==========================================
# ECS Module Outputs
# ==========================================

output "cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.api.name
}

output "service_arn" {
  description = "ECS Service ARN"
  value       = aws_ecs_service.api.id
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Load balancer hosted zone ID"
  value       = aws_lb.main.zone_id
}

output "load_balancer_arn" {
  description = "Load balancer ARN"
  value       = aws_lb.main.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.api.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.api.arn
}

output "task_definition_arn" {
  description = "ECS Task definition ARN"
  value       = aws_ecs_task_definition.api.arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "target_group_arn" {
  description = "ALB target group ARN"
  value       = aws_lb_target_group.api.arn
}

output "api_url" {
  description = "API URL"
  value       = "http://${aws_lb.main.dns_name}"
}