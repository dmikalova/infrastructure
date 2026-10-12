stack {
  name        = "den Secrets"
  description = "The one secret den reads at runtime, and the installer secrets it must not"
  id          = "den-secrets"
  tags        = ["den", "sops"]

  # The tailnet key is folded into the runtime secret, so it has to exist first.
  after = ["/tailscale/tailnet"]
}
