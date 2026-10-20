stack {
  name        = "den Secrets"
  description = "The one secret den reads at runtime, and the installer secrets it must not"
  id          = "den-secrets"
  tags        = ["den", "sops"]

  # The tailnet key, the backup credentials and the healthcheck URL are folded
  # into the runtime secret, so all three have to exist first.
  after = [
    "/backblaze/den-backup",
    "/gcp/apps/kestrel",
    "/tailscale/tailnet",
  ]
}
