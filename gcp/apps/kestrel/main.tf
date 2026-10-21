# kestrel Cloud Run service
#
# kestrel watches dead-man's switches. This stack is the registry: a check
# exists because it is declared here, and nowhere else. Terraform mints the
# token, kestrel reconciles its table to match, and the ping URL is published
# in a secret for the job that has to call it.

locals {
  app_name        = "kestrel"
  domain          = "mklv.tech"
  discord_secrets = provider::sops::file("${local.repo_root}/secrets/discord.sops.json").data

  # The custom domain is predictable, unlike the generated run.app URL, so the
  # ping URL can be composed before the service exists. That is what keeps the
  # token secret and the Cloud Run service out of a dependency cycle.
  base_url = "https://${local.app_name}.${local.domain}"

  # The checks. period_seconds is the job's schedule; grace_seconds is how late
  # it may be before kestrel says anything.
  #
  # One check per job, not one per host. A single den check would let a healthy
  # snapraid mask a dead kopia, because either ping resets the same switch, and
  # the alert could only say den went quiet rather than which job stopped.
  #
  # Both jobs run daily, so the period is a day. Grace covers how long the job
  # itself may take, because the deadline runs from the previous success: a
  # backup that starts on schedule and takes ten hours still pings ten hours
  # late. Twelve hours matches kopia-backup.service's TimeoutStartSec.
  checks = {
    # den/mgmt/.../kopia-backup.timer, 22:00 with a 30 minute jitter.
    KOPIA_BACKUP = {
      period_seconds = 86400
      grace_seconds  = 43200
    }

    # den/mgmt/.../snapraid-sync.timer, daily with a 30 minute jitter.
    SNAPRAID_SYNC = {
      period_seconds = 86400
      grace_seconds  = 43200
    }
  }

  ping_urls = {
    for name, check in local.checks :
    name => "${local.base_url}/ping/${random_password.check_token[name].result}"
  }
}

# One token per check. It is the whole credential, so it is long and it never
# leaves Secret Manager in plain form.
resource "random_password" "check_token" {
  for_each = local.checks

  length  = 48
  special = false
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

module "cloud_run" {
  source = "${local.modules_dir}/gcp/cloud-run-app"

  app_name       = local.app_name
  domain         = local.domain
  gcp_project_id = local.project_id
  gcp_region     = local.gcp_region

  # Five minutes is the real alerting resolution. Grace, not this, decides how
  # late a job may be.
  scheduled_jobs = [
    {
      name     = "sweep"
      schedule = "*/5 * * * *"
      path     = "/api/sweep"
    },
  ]

  secrets = {
    # CI reads the session URL to apply db/schema.hcl. The app itself uses the
    # transaction pooler, which is why internal/store speaks simple protocol.
    DATABASE_URL_SESSION     = module.app_database.database_url_session
    DATABASE_URL_TRANSACTION = module.app_database.database_url_transaction
    # An outage of a backup is maintenance, so it shares den's channel rather
    # than splitting into one nobody watches.
    DISCORD_WEBHOOK = local.discord_secrets.MAINTENANCE_WEBHOOK_URL
    CHECKS = jsonencode([
      for name, check in local.checks : {
        name           = name
        token          = random_password.check_token[name].result
        period_seconds = check.period_seconds
        grace_seconds  = check.grace_seconds
      }
    ])
    # The only thing that authorizes the sweep. Composed rather than read from
    # the module output, because the module mounts this secret and reading it
    # back would be a cycle. The name is fixed by the module.
    SWEEP_SERVICE_ACCOUNT = "${local.app_name}-scheduler@${local.project_id}.iam.gserviceaccount.com"
  }
}

# The ping URLs, for the stacks that configure the jobs doing the pinging.
# Published as a secret rather than a stack output so a consumer reads it with
# the same secret-manager-secret-data module it already uses.
module "check_urls" {
  source = "${local.modules_dir}/gcp/secret-manager-project-secret"

  project_id = local.project_id
  secret_id  = "kestrel-checks"
  data       = local.ping_urls
}
