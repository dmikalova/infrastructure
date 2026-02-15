output "secrets" {
  description = "Map of local name to secret version object"
  sensitive   = true
  value       = data.google_secret_manager_secret_version.main
}
