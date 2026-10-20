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

# Created by the Backblaze stack, which owns the bucket and the key that
# reaches it. Folded in here because den reads one secret and this is it.
module "backup" {
  source = "${local.modules_dir}/gcp/secret-manager-secret-data"

  project_id = local.project_id
  secrets = {
    den = "den-backup"
  }
}

# Created by the kestrel stack, which declares the check and mints its token.
# den is told the URL, never the token, and the URL is the whole credential.
module "healthcheck" {
  source = "${local.modules_dir}/gcp/secret-manager-secret-data"

  project_id = local.project_id
  secrets = {
    kestrel = "kestrel-checks"
  }
}

# Samba keeps its own password database, so the login account's password does
# not reach it. Chosen rather than generated: a Mac asks for it at the Finder
# connect prompt, and a passphrase someone can read off a phone beats one that
# needs a gcloud login to recover.
module "host_secret" {
  source = "${local.modules_dir}/gcp/secret-manager-project-secret"

  project_id = local.project_id
  secret_id  = "den-host"
  data = {
    # The offsite repository: where kopia writes, the bucket-scoped key that
    # lets it, and the password that makes the ciphertext readable. The
    # endpoint and region are here because kopia reaches the bucket over
    # Backblaze's S3-compatible API; the B2 native API is closed to this key.
    B2_BUCKET   = module.backup.json.den.B2_BUCKET
    B2_ENDPOINT = module.backup.json.den.B2_ENDPOINT
    B2_KEY      = module.backup.json.den.B2_KEY
    B2_KEY_ID   = module.backup.json.den.B2_KEY_ID
    B2_REGION   = module.backup.json.den.B2_REGION
    # den's alerts are maintenance alerts, so they share the maintenance
    # webhook rather than splitting into a channel nobody watches.
    DISCORD_WEBHOOK_URL = local.discord_secrets.MAINTENANCE_WEBHOOK_URL
    # The dead-man's switch den pings after a successful boot and after each
    # nightly job. kestrel declares the check; this is only the URL it minted.
    HEALTHCHECK_URL = module.healthcheck.json.kestrel.DEN
    # Chosen rather than generated, and kept in SOPS beside the LUKS
    # passphrase. It is the only secret in the backup path that cannot be
    # reissued: lose it and the bucket is noise. SOPS means a clone of this
    # repository and the Bitwarden age key recover it with GCP gone.
    KOPIA_PASSWORD = local.den_secrets.KOPIA_PASSWORD
    # Changing it silently breaks every connected client, including a Time
    # Machine target that then stops backing up and says nothing useful.
    SAMBA_PASSWORD    = local.den_secrets.SAMBA_PASSWORD
    TAILSCALE_AUTHKEY = module.tailnet.json.den.AUTHKEY
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

# Scoped to this one account on purpose. roles/iam.serviceAccountKeyAdmin at
# the project level would let anything running as tofu-ci mint a key for
# tofu-ci itself, which is a permanent copy of project admin. Here the worst
# it can mint is another den-host key, and den-host reads one secret.
resource "google_service_account_iam_member" "tofu_mints_den_host_key" {
  member             = "serviceAccount:${local.service_account_id}"
  role               = "roles/iam.serviceAccountKeyAdmin"
  service_account_id = google_service_account.den_host.name
}

# Minted here rather than on den so the key has a declared owner. A key den
# issued itself would outlive a rebuild with nothing tracking it, and revoking
# it would mean first discovering that it existed. Rotate with -replace.
resource "google_service_account_key" "den_host" {
  service_account_id = google_service_account.den_host.name

  depends_on = [google_service_account_iam_member.tofu_mints_den_host_key]
}

resource "google_secret_manager_secret_iam_member" "den_host_reads_host_secret" {
  member    = "serviceAccount:${google_service_account.den_host.email}"
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  secret_id = module.host_secret.secret_id
}
