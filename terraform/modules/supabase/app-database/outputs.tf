# Outputs for app-database module

output "secret_id" {
  description = "Secret Manager secret ID for the app's DATABASE_URL"
  value       = google_secret_manager_secret.database_url.secret_id
}

output "schema_name" {
  description = "Name of the PostgreSQL schema created for this app"
  value       = local.schema_name
}

output "role_name" {
  description = "Name of the PostgreSQL role created for this app"
  value       = local.role_name
}
