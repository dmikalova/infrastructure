# den's offsite copy.
#
# snapraid survives a dead drive; it does not survive a deleted file, a bad
# write that syncs to parity, or the apartment burning down. This bucket is the
# only copy of den's data that is not in the same room as den.
#
# kopia on den writes here. It encrypts client side, so Backblaze holds
# ciphertext and only the repository password makes it readable. That password
# is not issued here; see den/secrets/main.tf.

locals {
  bucket_name = "mklv-den-backup"

  # kopia talks S3, not the B2 native API, so it needs the host and the region
  # rather than the URL. Both are properties of the account's cluster, which is
  # why they are read rather than written down.
  s3_host   = replace(data.b2_account_info.this.s3_api_url, "https://", "")
  s3_region = split(".", local.s3_host)[1]
}

data "b2_account_info" "this" {}

resource "b2_bucket" "den_backup" {
  bucket_name = local.bucket_name
  bucket_type = "allPrivate"

  # kopia deletes its own blobs during maintenance, which in B2 only hides
  # them. Without this rule every blob kopia ever wrote is billed forever.
  # Thirty days is deliberate: it is the window in which a deletion made by
  # mistake, or by something holding den's key, can still be undone.
  lifecycle_rules {
    days_from_hiding_to_deleting                           = 30
    days_from_starting_to_canceling_unfinished_large_files = 1
    file_name_prefix                                       = ""
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Scoped to this one bucket, never the master key. A key that can reach every
# bucket is a key that can delete the backup of everything.
#
# deleteFiles is granted because kopia maintenance needs it. The lifecycle rule
# above is what makes that safe: a delete hides the version for thirty days
# rather than removing it.
resource "b2_application_key" "den" {
  bucket_ids = [b2_bucket.den_backup.bucket_id]
  capabilities = [
    "deleteFiles",
    "listBuckets",
    "listFiles",
    "readFiles",
    "writeFiles",
  ]
  key_name = "den-backup"
}

# Not bound to any identity here. den reads one secret, den-host, and the den
# secrets stack folds these values into it.
#
# The repository password is deliberately absent: Backblaze issues the bucket
# and the key, but nobody issues the encryption password. It lives in SOPS
# beside the LUKS passphrase so it is readable with GCP gone. See
# den/secrets/main.tf.
module "backup_secret" {
  source = "${local.modules_dir}/gcp/secret-manager-project-secret"

  project_id = local.project_id
  secret_id  = "den-backup"
  data = {
    B2_BUCKET   = b2_bucket.den_backup.bucket_name
    B2_ENDPOINT = local.s3_host
    B2_KEY      = b2_application_key.den.application_key
    B2_KEY_ID   = b2_application_key.den.application_key_id
    B2_REGION   = local.s3_region
  }
}
