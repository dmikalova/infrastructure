output "secret_id" {
  description = "The secret_id of the created secret"
  value       = google_secret_manager_secret.main.secret_id
}

output "secret_name" {
  description = "The resource name of the created secret"
  value       = google_secret_manager_secret.main.name
}

output "version" {
  description = "The secret version resource"
  value       = google_secret_manager_secret_version.main
}
