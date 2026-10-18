stack {
  name        = "den Secrets"
  description = "The one secret den reads at runtime, and the installer secrets it must not"
  id          = "den-secrets"
  tags        = ["den", "sops"]

  # The tailnet key and the backup credentials are folded into the runtime
  # secret, so both have to exist first.
  after = [
    "/backblaze/den-backup",
    "/tailscale/tailnet",
  ]
}
