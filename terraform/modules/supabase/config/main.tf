# Supabase Config module
#
# Reads Supabase project config from GCP Secret Manager.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

data "google_secret_manager_secret_version" "config" {
  project = var.project_id
  secret  = var.secret_name
}
