# Supabase project module
#
# Creates a Supabase project and stores connection details in GCP Secret Manager.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.7"
    }
  }
}

locals {
  admin_url = "postgresql://postgres.${supabase_project.main.id}:${random_password.db_password.result}@aws-0-${supabase_project.main.region}.pooler.supabase.com:6543/postgres"
}

# Generate secure database password
resource "random_password" "db_password" {
  length  = 32
  special = false
}

# Create Supabase project
resource "supabase_project" "main" {
  database_password = random_password.db_password.result
  name              = var.name
  organization_id   = var.organization_id
  region            = var.region
}

# Configure connection pooling
resource "supabase_settings" "main" {
  project_ref = supabase_project.main.id

  api = jsonencode({
    db_pool_config = {
      pool_mode = "transaction"
    }
  })
}

# Store admin connection URL in Secret Manager
resource "google_secret_manager_secret" "admin_url" {
  project   = var.gcp_project_id
  secret_id = "supabase-${var.name}-admin-url"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "admin_url" {
  secret      = google_secret_manager_secret.admin_url.id
  secret_data = local.admin_url
}

# Store project ref for app-database module
resource "google_secret_manager_secret" "project_ref" {
  project   = var.gcp_project_id
  secret_id = "supabase-${var.name}-project-ref"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "project_ref" {
  secret      = google_secret_manager_secret.project_ref.id
  secret_data = supabase_project.main.id
}

# Store region for app-database module
resource "google_secret_manager_secret" "region" {
  project   = var.gcp_project_id
  secret_id = "supabase-${var.name}-region"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "region" {
  secret      = google_secret_manager_secret.region.id
  secret_data = supabase_project.main.region
}
