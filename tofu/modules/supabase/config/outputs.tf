output "values" {
  description = "Decoded Supabase project configuration"
  sensitive   = true
  value       = jsondecode(data.google_secret_manager_secret_version.config.secret_data)
}
