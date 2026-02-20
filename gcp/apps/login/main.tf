# login Cloud Run service
#
# Multi-domain login portal using Supabase Auth for Google OAuth.

locals {
  app_name              = "login"
  supabase_project_name = "mklv"

  gcp_secrets      = provider::sops::file("${local.repo_root}/secrets/gcp.sops.json").data
  supabase_secrets = provider::sops::file("${local.repo_root}/secrets/supabase.sops.json").data

  # Domains this login service handles
  primary_domain = "mklv.tech"
  additional_domains = [
    "keyforge.cards",
  ]
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
  domain                             = local.primary_domain
  gcp_project_id                     = local.project_id
  gcp_region                         = local.gcp_region
  modules_dir                        = local.modules_dir

  existing_secrets = {
    "supabase-mklv-publishable-key" = {
      env_name = "SUPABASE_PUBLISHABLE_KEY"
    }
    "supabase-mklv-url" = {
      env_name = "SUPABASE_URL"
    }
  }

  secrets = {
    "login-google-client-id" = {
      env_name = "GOOGLE_CLIENT_ID"
      value    = local.gcp_secrets.LOGIN_GOOGLE_CLIENT_ID
    }
    "login-supabase-jwt-key" = {
      env_name = "SUPABASE_JWT_KEY"
      value    = local.supabase_secrets.SUPABASE_MKLV_JWT_KEY
    }
  }
}

# Additional Domain Mappings

# Domain mappings for additional domains
resource "google_cloud_run_domain_mapping" "additional" {
  for_each = toset(local.additional_domains)

  location = local.gcp_region
  name     = "${local.app_name}.${each.value}"
  project  = local.project_id

  metadata {
    namespace = local.project_id
  }

  spec {
    route_name = module.cloud_run.service_name
  }
}

# CNAME records for additional domains
resource "google_dns_record_set" "additional" {
  for_each = toset(local.additional_domains)

  managed_zone = replace(each.value, ".", "-")
  name         = "${local.app_name}.${each.value}."
  project      = local.project_id
  rrdatas      = ["ghs.googlehosted.com."]
  ttl          = 300
  type         = "CNAME"
}

# Outputs

output "service_url" {
  description = "Cloud Run service URL"
  value       = module.cloud_run.service_url
}

output "domain_urls" {
  description = "Custom domain URLs"
  value = concat(
    ["https://${local.app_name}.${local.primary_domain}"],
    [for d in local.additional_domains : "https://${local.app_name}.${d}"]
  )
}
