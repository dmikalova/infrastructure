# Outputs for GCP Baseline stack

output "ci_service_account_email" {
  description = "CI/CD service account email"
  value       = module.ci_service_account.email
}

output "ci_service_account_id" {
  description = "CI/CD service account ID"
  value       = module.ci_service_account.id
}

output "project_id" {
  description = "GCP project ID"
  value       = local.project_id
}

output "state_bucket_name" {
  description = "Terraform state bucket name"
  value       = module.state_bucket.name
}

output "state_bucket_url" {
  description = "Terraform state bucket URL"
  value       = module.state_bucket.url
}
