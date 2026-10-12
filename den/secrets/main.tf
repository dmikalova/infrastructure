# den reads exactly one secret, and this stack decides what is in it.
#
# Everything den needs at runtime is bundled into a single JSON blob so that
# the host service account carries a single binding. The list of keys below is
# the whole of what a compromised den can reach.

locals {
  den_secrets     = provider::sops::file("${local.repo_root}/secrets/den.sops.json").data
  discord_secrets = provider::sops::file("${local.repo_root}/secrets/discord.sops.json").data
  owner_email     = provider::sops::file("${local.repo_root}/secrets/dmikalova.sops.json").data.email
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

# These build the machine. den must never read them: root on den would then
# hold the passphrase to den's own disk, which defeats the encryption.
module "install_secret" {
  source = "${local.modules_dir}/gcp/secret-manager-project-secret"

  project_id = local.project_id
  secret_id  = "den-install"
  data = {
    LUKS_PASSPHRASE = local.den_secrets.LUKS_PASSPHRASE
    PASSWORD        = local.den_secrets.PASSWORD
  }
}

# The host identity. No key is created here, and none is stored anywhere: den
# mints one at bootstrap, seals it to its TPM, and holds the only copy.
resource "google_service_account" "den_host" {
  account_id   = "den-host"
  description  = "den reads its own runtime secret and nothing else"
  display_name = "den Host"
  project      = local.project_id
}

resource "google_secret_manager_secret_iam_member" "den_host_reads_host_secret" {
  member    = "serviceAccount:${google_service_account.den_host.email}"
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = module.host_secret.secret_id
}

# Only a human at a laptop builds a machine.
resource "google_secret_manager_secret_iam_member" "owner_reads_install_secret" {
  member    = "user:${local.owner_email}"
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = module.install_secret.secret_id
}
