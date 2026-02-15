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

# Store all secrets in Secret Manager
module "secrets" {
  source = "${var.modules_dir}/gcp/secret-manager-secret"

  project_id = var.gcp_project_id
  secrets = {
    # Direct connection (for Terraform/admin operations)
    "supabase-${var.name}-db-direct-host" = "db.${supabase_project.main.id}.supabase.co"
    "supabase-${var.name}-db-direct-port" = "5432"
    "supabase-${var.name}-db-direct-user" = "postgres"
    # Pooler connection (for app runtime)
    "supabase-${var.name}-admin-url"      = local.admin_url
    "supabase-${var.name}-db-host"        = "aws-0-${supabase_project.main.region}.pooler.supabase.com"
    "supabase-${var.name}-db-name"        = "postgres"
    "supabase-${var.name}-db-password"    = random_password.db_password.result
    "supabase-${var.name}-db-port"        = "6543"
    "supabase-${var.name}-db-user"        = "postgres.${supabase_project.main.id}"
    "supabase-${var.name}-project-ref"    = supabase_project.main.id
    "supabase-${var.name}-region"         = supabase_project.main.region
  }
}
