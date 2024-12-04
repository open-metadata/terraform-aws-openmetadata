output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.rds.db_instance_arn
}

output "db_instance_identifier" {
  description = "The identifier of the RDS instance"
  value       = module.rds.db_instance_identifier
}

output "db_instance_name" {
  description = "The database name"
  value       = module.rds.db_instance_name
}

output "db_instance_port" {
  description = "The database port"
  value       = module.rds.db_instance_port
}
