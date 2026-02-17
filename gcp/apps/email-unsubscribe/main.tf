# email-unsubscribe Cloud Run service
#
# App-specific configuration using the cloud-run-app module.

locals {
  app_name              = "email-unsubscribe"
  supabase_project_name = "mklv"

  gcp_secrets = provider::sops::file("${local.repo_root}/secrets/gcp.sops.json").data
}

# Database Setup

# Lookup Supabase database connection secrets
module "db_secrets" {
  source = "${local.modules_dir}/gcp/secret-manager-secret-data"

  project_id = local.project_id
  secrets = {
    db_host     = "supabase-${local.supabase_project_name}-db-host"
    db_name     = "supabase-${local.supabase_project_name}-db-name"
    db_password = "supabase-${local.supabase_project_name}-db-password"
    db_port     = "supabase-${local.supabase_project_name}-db-port"
    db_user     = "supabase-${local.supabase_project_name}-db-user"
  }
}

# Configure postgresql provider with pooler connection (IPv4-compatible)
provider "postgresql" {
  connect_timeout = 15
  database        = module.db_secrets.secrets["db_name"].secret_data
  host            = module.db_secrets.secrets["db_host"].secret_data
  password        = module.db_secrets.secrets["db_password"].secret_data
  port            = tonumber(module.db_secrets.secrets["db_port"].secret_data)
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

  app_name           = local.app_name
  database_secret_id = module.app_database.secret_id
  domain             = "mklv.tech"
  gcp_project_id     = local.project_id
  gcp_region         = local.gcp_region
  modules_dir        = local.modules_dir
  secrets = {
    "email-unsubscribe-encryption-key" = {
      env_name = "ENCRYPTION_KEY"
      value    = local.gcp_secrets.EMAIL_UNSUBSCRIBE_ENCRYPTION_KEY
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
  }
}

# Outputs

output "service_url" {
  description = "Cloud Run service URL"
  value       = module.cloud_run.service_url
}
