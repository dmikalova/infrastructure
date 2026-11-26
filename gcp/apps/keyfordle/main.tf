# keyfordle Cloud Run service
#
# The daily KeyForge card-guessing game at keyfordle.keyforge.cards. It is a
# port of KeyFordle from KFStats. Postgres holds the daily card and the daily
# play counts. The card pool is embedded in the image.

locals {
  app_name = "keyfordle"
  domain   = "keyforge.cards"
}

# Database

module "supabase_config" {
  source = "${local.modules_dir}/supabase/config"

  project_id  = local.project_id
  secret_name = "supabase-mklv"
}

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

module "app_database" {
  source = "${local.modules_dir}/supabase/app-database"

  app_name             = local.app_name
  supabase_project_ref = module.supabase_config.values.project_ref
  supabase_region      = module.supabase_config.values.region
}

# Cloud Run
#
# subdomain defaults to app_name, so the module maps keyfordle.keyforge.cards
# and creates its CNAME in the keyforge-cards managed zone.

module "cloud_run" {
  source = "${local.modules_dir}/gcp/cloud-run-app"

  app_name       = local.app_name
  domain         = local.domain
  gcp_project_id = local.project_id
  gcp_region     = local.gcp_region

  secrets = {
    # CI reads the session URL to apply db/schema.hcl. The app uses the
    # transaction pooler.
    DATABASE_URL_SESSION     = module.app_database.database_url_session
    DATABASE_URL_TRANSACTION = module.app_database.database_url_transaction
  }
}
