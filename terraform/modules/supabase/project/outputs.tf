# Outputs for supabase-project module

output "config" {
  description = "Supabase project configuration (all connection details)"
  value       = jsondecode(google_secret_manager_secret_version.config.secret_data)
  sensitive   = true
}

output "project_id" {
  description = "Supabase project reference ID"
  value       = supabase_project.main.id
}

output "project_name" {
  description = "Supabase project name"
  value       = supabase_project.main.name
}

output "secret_id" {
  description = "Secret Manager secret ID for the supabase config"
  value       = google_secret_manager_secret.config.secret_id
}

output "supabase_region" {
  description = "Supabase project region"
  value       = supabase_project.main.region
}
