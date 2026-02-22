# todos Cloud Run service
#
# App-specific configuration using the cloud-run-app module.

locals {
  app_name              = "todos"
  supabase_project_name = "mklv"

  supabase_secrets = provider::sops::file("${local.repo_root}/secrets/supabase.sops.json").data
}

# Database Setup

# Lookup Supabase database connection secrets
module "db_secrets" {
  source = "${local.modules_dir}/gcp/secret-manager-secret-data"

  project_id = local.project_id
  secrets = {
    db_name         = "supabase-${local.supabase_project_name}-db-name"
    db_password     = "supabase-${local.supabase_project_name}-db-password"
    db_session_host = "supabase-${local.supabase_project_name}-db-session-host"
    db_session_port = "supabase-${local.supabase_project_name}-db-session-port"
    db_user         = "supabase-${local.supabase_project_name}-db-user"
  }
}

# Configure postgresql provider with session pooler
# Session pooler (port 5432): IPv4 + prepared statements - required for Terraform DDL
# Transaction pooler (port 6543): IPv4, no prepared statements - used for app runtime
provider "postgresql" {
  connect_timeout = 15
  database        = module.db_secrets.secrets["db_name"].secret_data
  host            = module.db_secrets.secrets["db_session_host"].secret_data
  password        = module.db_secrets.secrets["db_password"].secret_data
  port            = tonumber(module.db_secrets.secrets["db_session_port"].secret_data)
  scheme          = "postgres"
  superuser       = false
  username        = module.db_secrets.secrets["db_user"].secret_data
}

# Create app-specific database with credentials stored in Secret Manager
module "app_database" {
  source = "${local.modules_dir}/supabase/app-database"

  app_name              = local.app_name
  gcp_project_id        = local.project_id
  modules_dir           = local.modules_dir
  supabase_project_name = local.supabase_project_name
}

# Cloud Run Service

module "cloud_run" {
  source = "${local.modules_dir}/gcp/cloud-run-app"

  app_name                           = local.app_name
  database_url_session_secret_id     = module.app_database.database_url_session_secret_id
  database_url_transaction_secret_id = module.app_database.database_url_transaction_secret_id
  domain                             = "mklv.tech"
  gcp_project_id                     = local.project_id
  gcp_region                         = local.gcp_region
  modules_dir                        = local.modules_dir

  existing_secrets = {
    "supabase-mklv-url" = {
      env_name = "SUPABASE_URL"
    }
  }

  secrets = {
    "todos-supabase-jwt-key" = {
      env_name = "SUPABASE_JWT_KEY"
      value    = local.supabase_secrets.SUPABASE_MKLV_JWT_KEY
    }
    "todos-supabase-publishable-key" = {
      env_name = "SUPABASE_PUBLISHABLE_KEY"
      value    = local.supabase_secrets.SUPABASE_PUBLISHABLE_KEY
    }
  }
}

# Outputs

output "service_url" {
  description = "Cloud Run service URL"
  value       = module.cloud_run.service_url
}
