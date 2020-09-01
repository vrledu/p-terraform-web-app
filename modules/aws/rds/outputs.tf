output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.db_instance.this_db_instance_endpoint
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.db_instance.this_db_instance_username
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = var.password
  sensitive   = true
}
