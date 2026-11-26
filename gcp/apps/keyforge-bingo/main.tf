# keyforge-bingo Cloud Run service
#
# The weekly KeyForge bingo board. Postgres holds every board and the spot
# suggestions. Suggestions are also posted to a Discord channel webhook.
#
# bingo.keyforge.cards used to map to the keyforge-cards service. This stack
# runs after keyforge-cards, so keyforge-cards drops its mapping and CNAME
# before this stack makes them.

locals {
  app_name        = "keyforge-bingo"
  domain          = "keyforge.cards"
  discord_secrets = provider::sops::file("${local.repo_root}/secrets/discord.sops.json").data
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
# The module maps bingo.keyforge.cards and creates its CNAME in the
# keyforge-cards managed zone.

module "cloud_run" {
  source = "${local.modules_dir}/gcp/cloud-run-app"

  app_name       = local.app_name
  subdomain      = "bingo"
  domain         = local.domain
  gcp_project_id = local.project_id
  gcp_region     = local.gcp_region

  secrets = {
    # The app posts suggestions here. Until the key is in discord.sops.json,
    # the app stores suggestions without posting them.
    BINGO_SUGGESTIONS_WEBHOOK_URL = try(local.discord_secrets.BINGO_SUGGESTIONS_WEBHOOK_URL, "")
    # CI reads the session URL to apply db/schema.hcl. The app uses the
    # transaction pooler.
    DATABASE_URL_SESSION     = module.app_database.database_url_session
    DATABASE_URL_TRANSACTION = module.app_database.database_url_transaction
  }
}
