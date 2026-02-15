# Outputs for app-database module

output "role_name" {
  description = "Name of the PostgreSQL role created for this app"
  value       = local.role_name
}

output "schema_name" {
  description = "Name of the PostgreSQL schema created for this app"
  value       = local.schema_name
}

output "secret_id" {
  description = "Secret Manager secret ID for the app's DATABASE_URL"
  value       = module.secrets.secrets["${var.app_name}-database-url"].secret_id
}
