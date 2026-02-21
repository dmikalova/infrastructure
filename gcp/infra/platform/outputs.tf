output "ghcr_proxy_url" {
  description = "Artifact Registry URL that proxies GHCR (use in Cloud Run deployments)"
  value       = "${local.gcp_region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.ghcr.repository_id}"
}

output "mcr_proxy_url" {
  description = "Artifact Registry URL that proxies MCR (use for Playwright, etc.)"
  value       = "${local.gcp_region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.mcr.repository_id}"
}
