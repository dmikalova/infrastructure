# GCP Platform Infrastructure
#
# Shared infrastructure for apps: container registry, domains, etc.

# Artifact Registry cleanup: keep images from last 3 months OR last 50 (whichever is more)
locals {
  artifact_cleanup_policies = [
    {
      id     = "keep-recent-3-months"
      action = "KEEP"
      condition = {
        newer_than = "7776000s" # 90 days
      }
      most_recent_versions = null
    },
    {
      id     = "keep-last-50"
      action = "KEEP"
      condition = null
      most_recent_versions = {
        keep_count = 50
      }
    },
    {
      id     = "delete-old"
      action = "DELETE"
      condition = {
        older_than = "7776000s" # 90 days
      }
      most_recent_versions = null
    },
  ]
}

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

  dynamic "cleanup_policies" {
    for_each = local.artifact_cleanup_policies
    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action

      dynamic "condition" {
        for_each = cleanup_policies.value.condition != null ? [cleanup_policies.value.condition] : []
        content {
          newer_than = try(condition.value.newer_than, null)
          older_than = try(condition.value.older_than, null)
        }
      }

      dynamic "most_recent_versions" {
        for_each = cleanup_policies.value.most_recent_versions != null ? [cleanup_policies.value.most_recent_versions] : []
        content {
          keep_count = most_recent_versions.value.keep_count
        }
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

  dynamic "cleanup_policies" {
    for_each = local.artifact_cleanup_policies
    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action

      dynamic "condition" {
        for_each = cleanup_policies.value.condition != null ? [cleanup_policies.value.condition] : []
        content {
          newer_than = try(condition.value.newer_than, null)
          older_than = try(condition.value.older_than, null)
        }
      }

      dynamic "most_recent_versions" {
        for_each = cleanup_policies.value.most_recent_versions != null ? [cleanup_policies.value.most_recent_versions] : []
        content {
          keep_count = most_recent_versions.value.keep_count
        }
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

# Discord webhooks for deploy and conformance notifications
#
# Every project's cicd workflow posts deploy results to #deploys, and the
# weekly project-standards conformance bot posts its run summary to
# #maintenance. Both read the webhook URLs through WIF as the deploy SA.

locals {
  discord_secrets = provider::sops::file("${local.repo_root}/secrets/discord.sops.json").data
}

module "discord_webhooks" {
  source = "${local.modules_dir}/gcp/secret-manager-secret"

  project_id = local.project_id
  secrets = {
    "discord-webhook-deploys"     = local.discord_secrets.DEPLOYS_WEBHOOK_URL
    "discord-webhook-maintenance" = local.discord_secrets.MAINTENANCE_WEBHOOK_URL
  }
}

resource "google_secret_manager_secret_iam_member" "discord_webhooks_deploy" {
  for_each = module.discord_webhooks.secrets

  member    = "serviceAccount:github-actions-deploy@${local.project_id}.iam.gserviceaccount.com"
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = each.value.secret_id
}

# GitHub token for automation
#
# The same full-permission token the github Terramate stacks use (SOPS
# GITHUB_TOKEN), synced for project-standards' weekly conformance workflow,
# which checks out and commits to repos with it. Only project-standards may
# read it: access is granted to that repository's own federated identity, not
# a service account other repos can impersonate. infrastructure already
# decrypts it from SOPS. Every other repo gets only PKG_READ_TOKEN.

locals {
  github_secrets  = provider::sops::file("${local.repo_root}/secrets/github.sops.json").data
  github_wif_pool = "projects/${data.google_project.main.number}/locations/global/workloadIdentityPools/github"
}

module "github_token" {
  source = "${local.modules_dir}/gcp/secret-manager-secret"

  project_id = local.project_id
  secrets = {
    "github-token" = local.github_secrets.GITHUB_TOKEN
  }
}

resource "google_secret_manager_secret_iam_member" "github_token_project_standards" {
  for_each = module.github_token.secrets

  member    = "principalSet://iam.googleapis.com/${local.github_wif_pool}/attribute.repository/dmikalova/project-standards"
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = each.value.secret_id
}
