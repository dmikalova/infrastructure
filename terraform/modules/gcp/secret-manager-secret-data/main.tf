# GCP Secret Manager Secrets Data module
#
# Reads multiple secrets from GCP Secret Manager.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

data "google_secret_manager_secret_version" "main" {
  for_each = var.secrets

  project = var.project_id
  secret  = each.value
}
