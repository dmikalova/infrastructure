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

  # Turns every destroy into a scheduled destroy. The version keeps its payload
  # and can be restored until the TTL elapses.
  version_destroy_ttl = var.version_destroy_ttl

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "main" {
  for_each = var.secrets

  secret      = google_secret_manager_secret.main[each.key].id
  secret_data = sensitive(each.value)

  # DISABLE leaked a version per rotation forever, and a disabled version still
  # bills as active. DELETE plus version_destroy_ttl bounds that at the TTL.
  deletion_policy = "DELETE"
}
