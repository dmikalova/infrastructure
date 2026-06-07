# Outputs for app-database module

output "database_url_session" {
  description = "PostgreSQL connection URL via session pooler (port 5432, prepared statements)"
  value       = "postgresql://${postgresql_role.app.name}.${var.supabase_project_ref}:${random_password.db_password.result}@aws-0-${var.supabase_region}.pooler.supabase.com:5432/postgres?options=-csearch_path%3D${local.schema_name}"
  sensitive   = true
}

output "database_url_transaction" {
  description = "PostgreSQL connection URL via transaction pooler (port 6543, connection pooling)"
  value       = "postgresql://${postgresql_role.app.name}.${var.supabase_project_ref}:${random_password.db_password.result}@aws-0-${var.supabase_region}.pooler.supabase.com:6543/postgres?options=-csearch_path%3D${local.schema_name}"
  sensitive   = true
}

output "role_name" {
  description = "Name of the PostgreSQL role created for this app"
  value       = local.role_name
}

output "schema_name" {
  description = "Name of the PostgreSQL schema created for this app"
  value       = local.schema_name
}
