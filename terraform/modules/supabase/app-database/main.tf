# App-specific database schema and credentials module
#
# Creates an isolated PostgreSQL schema with dedicated role and credentials.
# Stores the app-specific connection string in GCP Secret Manager.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.25"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

locals {
  schema_name = replace(var.app_name, "-", "_")
  role_name   = "${var.app_name}-role"
}

# Read admin connection URL from Secret Manager
data "google_secret_manager_secret_version" "admin_url" {
  project = var.gcp_project_id
  secret  = "supabase-${var.supabase_project_name}-admin-url"
}

# Read project ref from Secret Manager
data "google_secret_manager_secret_version" "project_ref" {
  project = var.gcp_project_id
  secret  = "supabase-${var.supabase_project_name}-project-ref"
}

# Read region from Secret Manager
data "google_secret_manager_secret_version" "region" {
  project = var.gcp_project_id
  secret  = "supabase-${var.supabase_project_name}-region"
}

# Generate password for this app's database role
resource "random_password" "db_password" {
  length  = 32
  special = false
}

# Create schema for this app
resource "postgresql_schema" "app" {
  name  = local.schema_name
  owner = postgresql_role.app.name
}

# Create role with login for this app
resource "postgresql_role" "app" {
  login    = true
  name     = local.role_name
  password = random_password.db_password.result
}

# Grant schema permissions (CREATE, USAGE)
resource "postgresql_grant" "schema" {
  database    = "postgres"
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"]
  role        = postgresql_role.app.name
  schema      = local.schema_name

  depends_on = [postgresql_schema.app]
}

# Grant table permissions (SELECT, INSERT, UPDATE, DELETE)
resource "postgresql_grant" "tables" {
  database    = "postgres"
  object_type = "table"
  privileges  = ["DELETE", "INSERT", "SELECT", "UPDATE"]
  role        = postgresql_role.app.name
  schema      = local.schema_name

  depends_on = [postgresql_schema.app]
}

# Store app-specific connection string in Secret Manager
resource "google_secret_manager_secret" "database_url" {
  project   = var.gcp_project_id
  secret_id = "${var.app_name}-database-url"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_url" {
  secret      = google_secret_manager_secret.database_url.id
  secret_data = "postgresql://${postgresql_role.app.name}.${data.google_secret_manager_secret_version.project_ref.secret_data}:${random_password.db_password.result}@aws-0-${data.google_secret_manager_secret_version.region.secret_data}.pooler.supabase.com:6543/postgres?options=-csearch_path%3D${local.schema_name}"
}
