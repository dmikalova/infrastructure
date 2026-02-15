# GCP Platform Infrastructure
#
# Shared infrastructure for apps: container registry, domains, etc.

# Artifact Registry - remote repository proxying GitHub Container Registry
# Allows Cloud Run to pull images from GHCR through Artifact Registry
resource "google_artifact_registry_repository" "ghcr" {
  description   = "Remote repository proxying GitHub Container Registry"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  location      = local.gcp_region
  project       = local.project_id
  repository_id = "ghcr"

  remote_repository_config {
    docker_repository {
      custom_repository {
        uri = "https://ghcr.io"
      }
    }
  }
}

# Grant Cloud Run default service agent access to pull from Artifact Registry
# This allows any Cloud Run service in the project to pull images
data "google_project" "main" {
  project_id = local.project_id
}

resource "google_artifact_registry_repository_iam_member" "ghcr_cloudrun" {
  location   = google_artifact_registry_repository.ghcr.location
  member     = "serviceAccount:service-${data.google_project.main.number}@serverless-robot-prod.iam.gserviceaccount.com"
  project    = local.project_id
  repository = google_artifact_registry_repository.ghcr.name
  role       = "roles/artifactregistry.reader"
}

# Grant GitHub Actions deploy SA access to pull images for deployment
resource "google_artifact_registry_repository_iam_member" "ghcr_deploy" {
  location   = google_artifact_registry_repository.ghcr.location
  member     = "serviceAccount:github-actions-deploy@${local.project_id}.iam.gserviceaccount.com"
  project    = local.project_id
  repository = google_artifact_registry_repository.ghcr.name
  role       = "roles/artifactregistry.reader"
}

# Output the GHCR proxy URL for use in workflows
output "ghcr_proxy_url" {
  description = "Artifact Registry URL that proxies GHCR (use in Cloud Run deployments)"
  value       = "${local.gcp_region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.ghcr.repository_id}"
}
