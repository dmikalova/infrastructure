# email-unsubscribe Cloud Run service
#
# App-specific configuration using the cloud-run-app module.

data "terraform_remote_state" "platform" {
  backend = "gcs"
  config = {
    bucket = "mklv-infrastructure-tfstate"
    prefix = "tfstate/gcp/infra/platform"
  }
}

locals {
  app_name         = "email-unsubscribe"
  gcp_secrets      = provider::sops::file("${local.repo_root}/secrets/gcp.sops.json").data
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
# Transaction pooler (port 6543): IPv4, no prepared statements - used for app runtime
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

# OAuth Setup Instructions
# OAuth consent screen and credentials cannot be fully automated via Terraform.
# Manual steps required:
# 1. Configure OAuth consent screen:
#    https://console.cloud.google.com/apis/credentials/consent?project=mklv-infrastructure
#    - User Type: External
#    - App name: Email Unsubscribe
#    - Scopes: gmail.readonly, gmail.modify, gmail.labels
#    - Test users: Add your email
# 2. Create OAuth credentials:
#    https://console.cloud.google.com/apis/credentials?project=mklv-infrastructure
#    - Create Credentials → OAuth client ID
#    - Application type: Web application
#    - Redirect URI: http://localhost:8000/oauth/callback
# 3. Store client ID and secret in secrets/gcp.sops.json (DONE)

# Enable Gmail API for OAuth email access
resource "google_project_service" "gmail" {
  disable_on_destroy = false
  project            = local.project_id
  service            = "gmail.googleapis.com"
}

module "cloud_run" {
  source = "${local.modules_dir}/gcp/cloud-run-app"

  app_name       = local.app_name
  domain         = "mklv.tech"
  gcp_project_id = local.project_id
  gcp_region     = local.gcp_region

  # GCS storage for Playwright traces
  bucket_lifecycle_rules = [
    {
      prefix   = "traces/"
      age_days = 90
    }
  ]

  # Playwright sidecar for browser automation (communicates via ws://localhost:3000)
  sidecars = [
    {
      name    = "playwright"
      image   = "${data.terraform_remote_state.platform.outputs.mcr_proxy_url}/playwright:v1.58.2-noble"
      cpu     = "1"
      memory  = "1Gi"
      command = ["npx", "playwright", "run-server", "--port", "3000"]
    }
  ]

  # Weekly scan job (Sunday 6am UTC / Saturday 10pm PST)
  scheduled_jobs = [
    {
      name     = "weekly-scan"
      schedule = "0 6 * * 0"
      path     = "/api/scan-all"
      method   = "POST"
      timezone = "UTC"
    }
  ]

  env_vars = {
    PLAYWRIGHT_WS_ENDPOINT = "ws://localhost:3000"
  }

  secrets = {
    DATABASE_URL_SESSION     = module.app_database.database_url_session
    DATABASE_URL_TRANSACTION = module.app_database.database_url_transaction
    ENCRYPTION_KEY_BASE64    = local.gcp_secrets.EMAIL_UNSUBSCRIBE_ENCRYPTION_KEY_BASE64
    GOOGLE_CLIENT_ID         = local.gcp_secrets.EMAIL_UNSUBSCRIBE_OAUTH_CLIENT_ID
    GOOGLE_CLIENT_SECRET     = local.gcp_secrets.EMAIL_UNSUBSCRIBE_OAUTH_CLIENT_SECRET
    GOOGLE_REDIRECT_URI      = local.gcp_secrets.EMAIL_UNSUBSCRIBE_OAUTH_REDIRECT_URI
    SUPABASE_JWT_KEY         = local.supabase_secrets.SUPABASE_MKLV_JWT_KEY
    SUPABASE_URL             = module.supabase_config.values.url
  }
}

# Outputs

output "service_url" {
  description = "Cloud Run service URL"
  value       = module.cloud_run.service_url
}
