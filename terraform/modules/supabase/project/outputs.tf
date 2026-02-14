# Outputs for supabase-project module

output "project_id" {
  description = "Supabase project reference ID"
  value       = supabase_project.main.id
}

output "project_name" {
  description = "Supabase project name"
  value       = supabase_project.main.name
}

output "region" {
  description = "Supabase project region"
  value       = supabase_project.main.region
}

output "admin_url_secret_id" {
  description = "Secret Manager secret ID for admin URL"
  value       = google_secret_manager_secret.admin_url.secret_id
}

output "project_ref_secret_id" {
  description = "Secret Manager secret ID for project ref"
  value       = google_secret_manager_secret.project_ref.secret_id
}

output "region_secret_id" {
  description = "Secret Manager secret ID for region"
  value       = google_secret_manager_secret.region.secret_id
}
