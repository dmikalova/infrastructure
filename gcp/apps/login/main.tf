# login Cloud Run service
#
# Multi-domain login portal using Supabase Auth for Google OAuth.

locals {
  app_name         = "login"
  gcp_secrets      = provider::sops::file("${local.repo_root}/secrets/gcp.sops.json").data
  supabase_secrets = provider::sops::file("${local.repo_root}/secrets/supabase.sops.json").data

  primary_domain = "mklv.tech"
  additional_domains = [
    "keyforge.cards",
  ]
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

# Create app-specific database with credentials stored in Secret Manager
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
  domain         = local.primary_domain
  gcp_project_id = local.project_id
  gcp_region     = local.gcp_region

  secrets = {
    DATABASE_URL_SESSION     = module.app_database.database_url_session
    DATABASE_URL_TRANSACTION = module.app_database.database_url_transaction
    GOOGLE_CLIENT_ID         = local.gcp_secrets.LOGIN_GOOGLE_CLIENT_ID
    SUPABASE_JWT_KEY         = local.supabase_secrets.SUPABASE_MKLV_JWT_KEY
    SUPABASE_PUBLISHABLE_KEY = module.supabase_config.values.publishable_key
    SUPABASE_URL             = module.supabase_config.values.url
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
