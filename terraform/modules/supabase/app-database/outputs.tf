# Outputs for app-database module

output "role_name" {
  description = "Name of the PostgreSQL role created for this app"
  value       = local.role_name
}

output "schema_name" {
  description = "Name of the PostgreSQL schema created for this app"
  value       = local.schema_name
}

output "secret_id_session" {
  description = "Secret Manager secret ID for DATABASE_URL_SESSION (session pooler, port 5432)"
  value       = module.secrets.secrets["${var.app_name}-database-url-session"].secret_id
}

output "secret_id_transaction" {
  description = "Secret Manager secret ID for DATABASE_URL_TRANSACTION (transaction pooler, port 6543)"
  value       = module.secrets.secrets["${var.app_name}-database-url-transaction"].secret_id
}
