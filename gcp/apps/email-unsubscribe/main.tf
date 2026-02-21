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
  app_name              = "email-unsubscribe"
  supabase_project_name = "mklv"

  gcp_secrets      = provider::sops::file("${local.repo_root}/secrets/gcp.sops.json").data
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

  app_name                           = local.app_name
  database_url_session_secret_id     = module.app_database.database_url_session_secret_id
  database_url_transaction_secret_id = module.app_database.database_url_transaction_secret_id
  domain                             = "mklv.tech"
  gcp_project_id                     = local.project_id
  gcp_region                         = local.gcp_region
  modules_dir                        = local.modules_dir

  # GCS private storage for Playwright traces
  private_bucket = true
  private_bucket_lifecycle_rules = [
    {
      prefix   = "traces/"
      age_days = 90
    }
  ]

  # GCS public storage for static frontend assets
  public_bucket      = true
  ci_service_account = "tofu-ci@mklv-infrastructure.iam.gserviceaccount.com"

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
      path     = "/api/scan"
      method   = "POST"
      timezone = "UTC"
    }
  ]

  env_vars = {
    PLAYWRIGHT_WS_ENDPOINT = "ws://localhost:3000"
  }

  existing_secrets = {
    "supabase-mklv-url" = {
      env_name = "SUPABASE_URL"
    }
  }

  secrets = {
    "email-unsubscribe-encryption-key-base64" = {
      env_name = "ENCRYPTION_KEY_BASE64"
      value    = local.gcp_secrets.EMAIL_UNSUBSCRIBE_ENCRYPTION_KEY_BASE64
    }
    "email-unsubscribe-oauth-client-id" = {
      env_name = "GOOGLE_CLIENT_ID"
      value    = local.gcp_secrets.EMAIL_UNSUBSCRIBE_OAUTH_CLIENT_ID
    }
    "email-unsubscribe-oauth-client-secret" = {
      env_name = "GOOGLE_CLIENT_SECRET"
      value    = local.gcp_secrets.EMAIL_UNSUBSCRIBE_OAUTH_CLIENT_SECRET
    }
    "email-unsubscribe-oauth-redirect-uri" = {
      env_name = "GOOGLE_REDIRECT_URI"
      value    = local.gcp_secrets.EMAIL_UNSUBSCRIBE_OAUTH_REDIRECT_URI
    }
    "email-unsubscribe-supabase-jwt-key" = {
      env_name = "SUPABASE_JWT_KEY"
      value    = local.supabase_secrets.SUPABASE_MKLV_JWT_KEY
    }
  }
}

# Outputs

output "service_url" {
  description = "Cloud Run service URL"
  value       = module.cloud_run.service_url
}
