# GCP Secret Manager Secrets module
#
# Creates multiple secrets and their versions in GCP Secret Manager.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

resource "google_secret_manager_secret" "main" {
  for_each = var.secrets

  project   = var.project_id
  secret_id = each.key

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "main" {
  for_each = var.secrets

  secret      = google_secret_manager_secret.main[each.key].id
  secret_data = sensitive(each.value)
}
