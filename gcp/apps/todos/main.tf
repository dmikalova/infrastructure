# todos Cloud Run service
#
# App-specific configuration using the cloud-run-app module.

locals {
  app_name         = "todos"
  supabase_secrets = provider::sops::file("${local.repo_root}/secrets/supabase.sops.json").data
}

# Database

module "supabase_config" {
  source = "${local.modules_dir}/supabase/config"

  project_id  = local.project_id
  secret_name = "supabase-mklv"
}

# Configure postgresql provider with session pooler
# Session pooler (port 5432): IPv4 + prepared statements - required for Terraform DDL
# Transaction pooler (port 6543): IPv4, no prepared statements - used for app runtimeprovider "postgresql" {
provider "postgresql" {
  connect_timeout = 15
  database        = module.supabase_config.values.db_name
  host            = module.supabase_config.values.db_session_host
  password        = module.supabase_config.values.db_password
  port            = tonumber(module.supabase_config.values.db_session_port)
  scheme          = "postgres"
  superuser       = false
  username        = module.supabase_config.values.db_user
}

module "app_database" {
  source = "${local.modules_dir}/supabase/app-database"

  app_name             = local.app_name
  supabase_project_ref = module.supabase_config.values.project_ref
  supabase_region      = module.supabase_config.values.region
}

# Cloud Run

module "cloud_run" {
  source = "${local.modules_dir}/gcp/cloud-run-app"

  app_name       = local.app_name
  domain         = "mklv.tech"
  gcp_project_id = local.project_id
  gcp_region     = local.gcp_region

  secrets = {
    DATABASE_URL_SESSION     = module.app_database.database_url_session
    DATABASE_URL_TRANSACTION = module.app_database.database_url_transaction
    SUPABASE_JWT_KEY         = local.supabase_secrets.SUPABASE_MKLV_JWT_KEY
    SUPABASE_PUBLISHABLE_KEY = local.supabase_secrets.SUPABASE_PUBLISHABLE_KEY
    SUPABASE_URL             = module.supabase_config.values.url
  }
}

# Outputs

output "service_url" {
  description = "Cloud Run service URL"
  value       = module.cloud_run.service_url
}
