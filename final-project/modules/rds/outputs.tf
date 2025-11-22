locals {
  computed_endpoint        = coalesce(try(aws_rds_cluster.this[0].endpoint, null), try(aws_db_instance.this[0].address, null))
  computed_reader_endpoint = try(aws_rds_cluster.this[0].reader_endpoint, null)
}

output "endpoint" {
  description = "Primary database endpoint (cluster endpoint for Aurora or instance address for RDS)"
  value       = local.computed_endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint (Aurora only, null for single RDS instance)"
  value       = local.computed_reader_endpoint
}

output "port" {
  description = "Database port"
  value       = 5432
}

output "security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
}

output "subnet_group_name" {
  description = "Name of the database subnet group"
  value       = aws_db_subnet_group.db.name
}


