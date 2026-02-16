output "github_token_base64" {
  description = "Base64-encoded GitHub token"
  sensitive   = true
  value       = base64encode(local.github_secrets.GITHUB_TOKEN)
}

output "repositories" {
  description = "All managed repositories"
  value       = module.repositories.repositories
}
