output "json" {
  description = "Map of local name to JSON-decoded secret data"
  sensitive   = true
  value = {
    for key, secret in data.google_secret_manager_secret_version.main :
    key => jsondecode(secret.secret_data)
  }
}

output "secrets" {
  description = "Map of local name to secret version object"
  sensitive   = true
  value       = data.google_secret_manager_secret_version.main
}
