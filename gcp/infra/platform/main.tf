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

# Artifact Registry - remote repository proxying Microsoft Container Registry
# Allows Cloud Run to pull images like Playwright from MCR
resource "google_artifact_registry_repository" "mcr" {
  description   = "Remote repository proxying Microsoft Container Registry"
  format        = "DOCKER"
  location      = local.gcp_region
  mode          = "REMOTE_REPOSITORY"
  project       = local.project_id
  repository_id = "mcr"

  remote_repository_config {
    docker_repository {
      custom_repository {
        uri = "https://mcr.microsoft.com"
      }
    }
  }
}

resource "google_artifact_registry_repository_iam_member" "mcr_cloudrun" {
  location   = google_artifact_registry_repository.mcr.location
  member     = "serviceAccount:service-${data.google_project.main.number}@serverless-robot-prod.iam.gserviceaccount.com"
  project    = local.project_id
  repository = google_artifact_registry_repository.mcr.name
  role       = "roles/artifactregistry.reader"
}

# Grant GitHub Actions deploy SA access to pull MCR images for deployment
resource "google_artifact_registry_repository_iam_member" "mcr_deploy" {
  location   = google_artifact_registry_repository.mcr.location
  member     = "serviceAccount:github-actions-deploy@${local.project_id}.iam.gserviceaccount.com"
  project    = local.project_id
  repository = google_artifact_registry_repository.mcr.name
  role       = "roles/artifactregistry.reader"
}
