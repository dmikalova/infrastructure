output "secrets" {
  description = "Map of secret_id to secret object"
  value       = google_secret_manager_secret.main
}

output "versions" {
  description = "Map of secret_id to secret version object"
  value       = google_secret_manager_secret_version.main
}
