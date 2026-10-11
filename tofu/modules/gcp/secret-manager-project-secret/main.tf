# GCP Secret Manager Project Secret
#
# Creates a single Secret Manager secret storing JSON-encoded data.
# Used for per-project/per-app configuration secrets.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

resource "google_secret_manager_secret" "main" {
  project   = var.project_id
  secret_id = var.secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "main" {
  secret      = google_secret_manager_secret.main.id
  secret_data = jsonencode(var.data)
}
