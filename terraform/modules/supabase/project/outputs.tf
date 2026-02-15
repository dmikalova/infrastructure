# Outputs for supabase-project module

output "project_id" {
  description = "Supabase project reference ID"
  value       = supabase_project.main.id
}

output "project_name" {
  description = "Supabase project name"
  value       = supabase_project.main.name
}

output "secret_ids" {
  description = "Map of secret names to their Secret Manager secret IDs"
  value       = { for k, v in module.secrets.secrets : k => v.secret_id }
}

output "supabase_region" {
  description = "Supabase project region"
  value       = supabase_project.main.region
}
