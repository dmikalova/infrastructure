# Supabase project module
#
# Creates a Supabase project and stores connection details in Secret Manager.

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
  region            = var.supabase_region
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

# Fetch API keys from Supabase
data "supabase_apikeys" "main" {
  project_ref = supabase_project.main.id
}

# Store connection details in Secret Manager
resource "google_secret_manager_secret" "config" {
  project   = var.gcp_project_id
  secret_id = "supabase-${var.name}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "config" {
  secret      = google_secret_manager_secret.config.id
  secret_data = jsonencode({
    # API keys
    publishable_key = data.supabase_apikeys.main.publishable_key
    # Direct connection (IPv6 only, for local admin operations)
    admin_url      = local.admin_url
    db_direct_host = "db.${supabase_project.main.id}.supabase.co"
    db_direct_port = "5432"
    db_direct_user = "postgres"
    # Session pooler (IPv4, prepared statements - for Terraform DDL in CI/CD)
    db_session_host = "aws-0-${supabase_project.main.region}.pooler.supabase.com"
    db_session_port = "5432"
    # Transaction pooler (IPv4, no prepared statements - for app runtime)
    db_host     = "aws-0-${supabase_project.main.region}.pooler.supabase.com"
    db_name     = "postgres"
    db_password = random_password.db_password.result
    db_port     = "6543"
    db_user     = "postgres.${supabase_project.main.id}"
    # Project metadata
    project_ref = supabase_project.main.id
    region      = supabase_project.main.region
    url         = "https://${supabase_project.main.id}.supabase.co"
  })
}
