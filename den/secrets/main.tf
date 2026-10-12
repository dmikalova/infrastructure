# den reads exactly one secret, and this stack decides what is in it.
#
# Everything den needs at runtime is bundled into a single JSON blob so that
# the host service account carries a single binding. The list of keys below is
# the whole of what a compromised den can reach.

locals {
  den_secrets     = provider::sops::file("${local.repo_root}/secrets/den.sops.json").data
  discord_secrets = provider::sops::file("${local.repo_root}/secrets/discord.sops.json").data
}

# Created by the tailnet stack, not here: a key that enrols machines cannot be
# issued by the machine it enrols.
module "tailnet" {
  source = "${local.modules_dir}/gcp/secret-manager-secret-data"

  project_id = local.project_id
  secrets = {
    den = "tailscale-den"
  }
}

module "host_secret" {
  source = "${local.modules_dir}/gcp/secret-manager-project-secret"

  project_id = local.project_id
  secret_id  = "den-host"
  data = {
    # TODO: give den its own webhook so an alert from den is distinguishable
    # from a maintenance alert, and so one can be revoked without the other.
    DISCORD_WEBHOOK_URL = local.discord_secrets.MAINTENANCE_WEBHOOK_URL
    TAILSCALE_AUTHKEY   = module.tailnet.json.den.AUTHKEY
  }
}

# These build the machine, and no binding is written for them: the project
# owner already reads every secret, so the absence of a grant is what keeps
# den out. den must not read these. Root on den holding the passphrase to
# den's own disk defeats the encryption, and den reading GCP_KEY here would
# let it re-fetch a key that had just been revoked.
module "install_secret" {
  source = "${local.modules_dir}/gcp/secret-manager-project-secret"

  project_id = local.project_id
  secret_id  = "den-install"
  data = {
    GCP_KEY         = base64decode(google_service_account_key.den_host.private_key)
    LUKS_PASSPHRASE = local.den_secrets.LUKS_PASSPHRASE
    PASSWORD        = local.den_secrets.PASSWORD
  }
}

# The host identity.
resource "google_service_account" "den_host" {
  account_id   = "den-host"
  description  = "den reads its own runtime secret and nothing else"
  display_name = "den Host"
  project      = local.project_id
}

# Minted here rather than on den so the key has a declared owner. A key den
# issued itself would outlive a rebuild with nothing tracking it, and revoking
# it would mean first discovering that it existed. Rotate with -replace.
resource "google_service_account_key" "den_host" {
  service_account_id = google_service_account.den_host.name
}

resource "google_secret_manager_secret_iam_member" "den_host_reads_host_secret" {
  member    = "serviceAccount:${google_service_account.den_host.email}"
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = module.host_secret.secret_id
}
